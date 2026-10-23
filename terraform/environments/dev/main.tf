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

