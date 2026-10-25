terraform {
  required_version = ">= 1.10.0, < 2.0.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 7.0"
    }
  }

  backend "gcs" {
    bucket = "sneak-tfstate-m1909523"
    prefix = "terraform/environments/prod"
  }
}

provider "google" {
  project = var.project_id
  region  = var.region

  default_labels = {
    environment = var.environment
    managed_by  = "terraform"
    project     = "sneak-platform"
  }
}