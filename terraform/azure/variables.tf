variable "subscription_id" {
  type        = string
  description = "Azure subscription ID."
}
variable "location" {
  type    = string
  default = "uksouth"
}
variable "name_prefix" {
  type    = string
  default = "sneak"
  validation {
    condition     = can(regex("^[a-z0-9-]{2,12}$", var.name_prefix))
    error_message = "Use 2-12 lowercase letters, digits or hyphens."
  }
}
variable "environment" {
  type    = string
  default = "dev"
  validation {
    condition     = contains(["dev", "test", "prod"], var.environment)
    error_message = "environment must be dev, test or prod."
  }
}
variable "aks_node_vm_size" {
  type    = string
  default = "Standard_D2s_v5"
}
variable "aks_min_node_count" {
  type    = number
  default = 1
}
variable "aks_max_node_count" {
  type    = number
  default = 3
}
variable "aks_api_server_authorized_ip_ranges" {
  type        = list(string)
  description = "Trusted public egress CIDRs allowed to access the AKS API server."
}
variable "tags" {
  type    = map(string)
  default = {}
}
