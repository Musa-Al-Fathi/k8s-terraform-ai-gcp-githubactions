resource "google_storage_bucket" "project_logs" {
  name                        = "sneak-${var.environment}-logs-m1909523"
  location                    = upper(var.region)
  uniform_bucket_level_access = true
  public_access_prevention    = "enforced"
  force_destroy               = true # dev only, so Day 3 teardown works

  versioning {
    enabled = true
  }

  lifecycle_rule {
    condition {
      age = 30
    }
    action {
      type = "Delete"
    }
  }
}

module "network" {
  source        = "../../modules/network"
  project_id    = var.project_id
  region        = var.region
  name          = var.environment
  subnet_cidr   = "10.10.0.0/20"
  pods_cidr     = "10.20.0.0/16"
  services_cidr = "10.30.0.0/20"

  depends_on = [google_project_service.apis]
}