locals {
  apis = [
    "compute.googleapis.com",
    "container.googleapis.com",
    "artifactregistry.googleapis.com",
    "iam.googleapis.com",
    "iamcredentials.googleapis.com",
    "sts.googleapis.com",
    "cloudresourcemanager.googleapis.com",
  ]

  environment_subnets = {
    dev = {
      cidr           = "10.20.0.0/20"
      pods_range     = "10.24.0.0/14"
      services_range = "10.28.0.0/20"
    }
    prod = {
      cidr           = "10.30.0.0/20"
      pods_range     = "10.32.0.0/14"
      services_range = "10.36.0.0/20"
    }
  }
}

resource "google_project_service" "apis" {
  for_each           = toset(local.apis)
  project            = var.project_id
  service            = each.value
  disable_on_destroy = false
}

# Shared networking is owned here, not independently by dev/prod state.
resource "google_compute_network" "platform" {
  project                 = var.project_id
  name                    = "sneak-vpc"
  auto_create_subnetworks = false
  routing_mode            = "REGIONAL"
  depends_on              = [google_project_service.apis]
}

resource "google_compute_subnetwork" "environment" {
  for_each                 = local.environment_subnets
  project                  = var.project_id
  name                     = "sneak-${each.key}-subnet"
  region                   = var.region
  network                  = google_compute_network.platform.id
  ip_cidr_range            = each.value.cidr
  private_ip_google_access = true

  secondary_ip_range {
    range_name    = "pods"
    ip_cidr_range = each.value.pods_range
  }

  secondary_ip_range {
    range_name    = "services"
    ip_cidr_range = each.value.services_range
  }
}

resource "google_artifact_registry_repository" "sneak" {
  project       = var.project_id
  location      = var.region
  repository_id = "sneak"
  format        = "DOCKER"
  depends_on    = [google_project_service.apis]
}

resource "google_service_account" "github_deployer" {
  project      = var.project_id
  account_id   = "github-deployer"
  display_name = "GitHub Actions deployer"
  depends_on   = [google_project_service.apis]
}

resource "google_artifact_registry_repository_iam_member" "deployer_push" {
  project    = var.project_id
  location   = var.region
  repository = google_artifact_registry_repository.sneak.repository_id
  role       = "roles/artifactregistry.writer"
  member     = "serviceAccount:${google_service_account.github_deployer.email}"
}

# Review this role and Kubernetes RBAC before using beyond a portfolio lab.
resource "google_project_iam_member" "deployer_gke" {
  project = var.project_id
  role    = "roles/container.developer"
  member  = "serviceAccount:${google_service_account.github_deployer.email}"
}

resource "google_iam_workload_identity_pool" "github" {
  project                   = var.project_id
  workload_identity_pool_id = "github"
  depends_on                = [google_project_service.apis]
}

resource "google_iam_workload_identity_pool_provider" "github" {
  project                            = var.project_id
  workload_identity_pool_id          = google_iam_workload_identity_pool.github.workload_identity_pool_id
  workload_identity_pool_provider_id = "github"

  attribute_mapping = {
    "google.subject"       = "assertion.sub"
    "attribute.repository" = "assertion.repository"
  }

  attribute_condition = "assertion.repository == \"${var.github_repo}\""

  oidc {
    issuer_uri = "https://token.actions.githubusercontent.com"
  }
}

resource "google_service_account_iam_member" "github_impersonate" {
  service_account_id = google_service_account.github_deployer.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.github.name}/attribute.repository/${var.github_repo}"
}
