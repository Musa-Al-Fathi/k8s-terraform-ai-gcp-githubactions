variable "project_id" {
  type = string
}

variable "region" {
  type = string
}

variable "zone" {
  type = string
}

variable "environment" {
  type = string
}

variable "registry_repository_id" {
  type        = string
  description = "Artifact Registry repository created by terraform/environments/shared."
}

variable "network_name" {
  type = string
}

variable "subnetwork_name" {
  type = string
}

variable "master_ipv4_cidr_block" {
  type = string
}

variable "master_authorized_cidr_blocks" {
  type = list(object({
    cidr_block   = string
    display_name = string
  }))
}

variable "release_channel" {
  type = string
}

variable "deletion_protection" {
  type = bool
}

variable "spot" {
  type = bool
}

variable "min_nodes" {
  type = number
}

variable "max_nodes" {
  type = number
}