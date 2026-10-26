module "gke" {
  source = "../../modules/gcp/gke"

  project_id                    = var.project_id
  environment                   = var.environment
  zone                          = var.zone
  network_name                  = var.network_name
  subnetwork_name               = var.subnetwork_name
  master_ipv4_cidr_block        = var.master_ipv4_cidr_block
  master_authorized_cidr_blocks = var.master_authorized_cidr_blocks
  release_channel               = var.release_channel
  deletion_protection           = var.deletion_protection
  spot                          = var.spot
  min_nodes                     = var.min_nodes
  max_nodes                     = var.max_nodes
}

# Artifact Registry is created and owned by the shared root.
resource "google_artifact_registry_repository_iam_member" "nodes_pull" {
  project    = var.project_id
  location   = var.region
  repository = var.registry_repository_id
  role       = "roles/artifactregistry.reader"
  member     = "serviceAccount:${module.gke.node_service_account_email}"
}