variable "project_id" {
  type = string
}

variable "environment" {
  type = string
}

variable "zone" {
  type = string
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