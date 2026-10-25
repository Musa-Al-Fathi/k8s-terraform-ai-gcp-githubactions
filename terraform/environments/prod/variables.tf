variable "project_id" {
  type = string
}

variable "region" {
  type = string
}

variable "github_repo" {
  type        = string
  description = "owner/repo allowed to deploy via OIDC"
}