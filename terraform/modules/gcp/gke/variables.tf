variable "project_id" {
  type = string
}

variable "environment" {
  type = string
}

variable "zone" {
  type = string
}

variable "network_name" {
  type        = string
  description = "Name of the shared VPC managed by the shared root."
}

variable "subnetwork_name" {
  type        = string
  description = "Environment-specific subnet with pods/services secondary ranges."
}

variable "master_ipv4_cidr_block" {
  type        = string
  description = "Dedicated /28 CIDR for the GKE control plane."
}

variable "release_channel" {
  type    = string
  default = "REGULAR"
}

variable "deletion_protection" {
  type    = bool
  default = true
}

variable "machine_type" {
  type    = string
  default = "e2-medium"
}

variable "spot" {
  type    = bool
  default = false
}

variable "min_nodes" {
  type    = number
  default = 1
}

variable "max_nodes" {
  type    = number
  default = 2
}