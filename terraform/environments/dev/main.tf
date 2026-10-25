module "gke" {
  source = "../../modules/gcp/gke"

  project_id          = var.project_id
  environment         = var.environment
  zone                = var.zone
  release_channel     = var.release_channel
  deletion_protection = var.deletion_protection
  spot                = var.spot
  min_nodes           = var.min_nodes
  max_nodes           = var.max_nodes
}

# Nodes pull images from the shared registry. Without this: ImagePullBackOff.
resource "google_artifact_registry_repository_iam_member" "nodes_pull" {
  project    = var.project_id
  location   = var.region
  repository = var.registry_repository_id
  role       = "roles/artifactregistry.reader"
  member     = "serviceAccount:${module.gke.node_service_account_email}"
}