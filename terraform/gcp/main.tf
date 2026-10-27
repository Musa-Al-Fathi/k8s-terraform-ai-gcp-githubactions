locals {
  name = "${var.name_prefix}-${var.environment}"
  labels = {
    environment = var.environment
    managed_by  = "terraform"
    project     = "kubernetes-platform"
  }
}
resource "google_project_service" "required" {
  for_each = toset([
    "artifactregistry.googleapis.com",
    "compute.googleapis.com",
    "container.googleapis.com",
    "iam.googleapis.com",
    "logging.googleapis.com",
    "monitoring.googleapis.com"
  ])
  project            = var.project_id
  service            = each.value
  disable_on_destroy = false
}
resource "google_compute_network" "platform" {
  name                    = "${local.name}-vpc"
  auto_create_subnetworks = false
  routing_mode            = "REGIONAL"
  depends_on              = [google_project_service.required]
}
resource "google_compute_subnetwork" "gke" {
  name                     = "${local.name}-subnet"
  region                   = var.region
  network                  = google_compute_network.platform.id
  ip_cidr_range            = "10.40.0.0/20"
  private_ip_google_access = true
  secondary_ip_range {
    range_name    = "${local.name}-pods"
    ip_cidr_range = "10.48.0.0/14"
  }
  secondary_ip_range {
    range_name    = "${local.name}-services"
    ip_cidr_range = "10.44.0.0/20"
  }
}
resource "google_artifact_registry_repository" "platform" {
  location      = var.region
  repository_id = "${local.name}-images"
  description   = "Container images for ${local.name} Kubernetes workloads"
  format        = "DOCKER"
  labels        = local.labels
}
resource "google_service_account" "nodes" {
  account_id   = "${local.name}-gke-nodes"
  display_name = "GKE node identity for ${local.name}"
}
resource "google_project_iam_member" "node_logging" {
  for_each = toset([
    "roles/logging.logWriter",
    "roles/monitoring.metricWriter",
    "roles/monitoring.viewer"
  ])
  project = var.project_id
  role    = each.value
  member  = "serviceAccount:${google_service_account.nodes.email}"
}
resource "google_project_iam_member" "nodes_pull" {
  project = var.project_id
  role    = "roles/artifactregistry.reader"
  member  = "serviceAccount:${google_service_account.nodes.email}"
}
resource "google_container_cluster" "platform" {
  name                     = "${local.name}-gke"
  location                 = var.zone
  network                  = google_compute_network.platform.id
  subnetwork               = google_compute_subnetwork.gke.id
  networking_mode          = "VPC_NATIVE"
  remove_default_node_pool = true
  initial_node_count       = 1
  deletion_protection      = var.deletion_protection
  resource_labels          = local.labels
  ip_allocation_policy {
    cluster_secondary_range_name  = google_compute_subnetwork.gke.secondary_ip_range[0].range_name
    services_secondary_range_name = google_compute_subnetwork.gke.secondary_ip_range[1].range_name
  }
  workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog"
  }
  master_authorized_networks_config {
    dynamic "cidr_blocks" {
      for_each = var.master_authorized_cidr_blocks
      content {
        cidr_block   = cidr_blocks.value.cidr_block
        display_name = cidr_blocks.value.display_name
      }
    }
  }
  depends_on = [
    google_project_service.required,
    google_project_iam_member.node_logging
  ]
}
resource "google_container_node_pool" "platform" {
  name     = "system"
  cluster  = google_container_cluster.platform.name
  location = var.zone
  autoscaling {
    min_node_count = var.min_node_count
    max_node_count = var.max_node_count
  }
  management {
    auto_repair  = true
    auto_upgrade = true
  }
  node_config {
    machine_type    = var.node_machine_type
    service_account = google_service_account.nodes.email
    oauth_scopes    = ["https://www.googleapis.com/auth/cloud-platform"]
    spot            = var.environment != "prod"
    labels          = local.labels
    metadata = {
      disable-legacy-endpoints = "true"
    }
    workload_metadata_config {
      mode = "GKE_METADATA"
    }
    shielded_instance_config {
      enable_secure_boot          = true
      enable_integrity_monitoring = true
    }
  }
  depends_on = [google_project_iam_member.nodes_pull]
}
