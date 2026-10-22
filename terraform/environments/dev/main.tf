
terraform {
  required_version = ">= 1.10.0, < 2.0.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 7.0"
    }
  }
}

provider "google" {
  project = "m1909523"
  region  = "europe-west2"
}

resource "google_storage_bucket" "project_logs" {
  name                        = "sneak-dev-logs-m1909523"
  location                    = "EUROPE-WEST2"
  uniform_bucket_level_access = true
  public_access_prevention    = "enforced"

  versioning {
    enabled = true
  }

  labels = {
    environment = "dev"
    managed_by  = "terraform"
    project     = "sneak-platform"
  }
}
