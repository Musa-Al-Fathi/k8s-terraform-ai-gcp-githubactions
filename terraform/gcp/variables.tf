variable "project_id" {
  type        = string
  description = "Existing GCP project ID with billing enabled."
}
variable "region" {
  type    = string
  default = "europe-west2"
}
variable "zone" {
  type    = string
  default = "europe-west2-a"
}
variable "name_prefix" {
  type    = string
  default = "sneak"
}
variable "environment" {
  type    = string
  default = "dev"
  validation {
    condition     = contains(["dev", "test", "prod"], var.environment)
    error_message = "environment must be dev, test or prod."
  }
}
variable "master_authorized_cidr_blocks" {
  type = list(object({
    cidr_block   = string
    display_name = string
  }))
  description = "Trusted public egress CIDRs allowed to reach the GKE control plane."
}
variable "node_machine_type" {
  type    = string
  default = "e2-medium"
}
variable "min_node_count" {
  type    = number
  default = 1
}
variable "max_node_count" {
  type    = number
  default = 3
}
variable "deletion_protection" {
  type    = bool
  default = false
}
