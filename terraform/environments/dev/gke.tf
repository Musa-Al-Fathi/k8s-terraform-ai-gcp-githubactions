module "gke" {
  source = "../../modules/gcp/gke"

  project_id          = var.project_id
  environment         = var.environment
  zone                = var.zone
  release_channel     = "RAPID"
  deletion_protection = false
  spot                = true
  min_nodes           = 1
  max_nodes           = 2

  depends_on = [google_project_service.apis]
}