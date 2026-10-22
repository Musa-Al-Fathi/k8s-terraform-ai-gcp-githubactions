terraform {
  backend "gcs" {
    bucket = "sneak-tfstate-m1909523"
    prefix = "terraform/environments/dev"
  }
}