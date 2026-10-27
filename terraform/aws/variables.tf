variable "aws_region" { type = string, default = "eu-west-2" }
variable "name_prefix" {
  type = string
  default = "sneak"
  validation {
    condition = can(regex("^[a-z][a-z0-9-]{1,10}$", var.name_prefix))
    error_message = "Use 2-11 lowercase letters, digits or hyphens and start with a letter."
  }
}
variable "environment" {
  type = string
  default = "dev"
  validation {
    condition = contains(["dev", "test", "prod"], var.environment)
    error_message = "environment must be dev, test or prod."
  }
}
variable "cluster_endpoint_public_access_cidrs" {
  type = list(string)
  description = "Trusted public IPv4 CIDRs allowed to reach EKS API. Replace the example CIDR before apply."
}
variable "eks_instance_types" { type = list(string), default = ["t3.medium"] }
variable "eks_min_size" { type = number, default = 1 }
variable "eks_desired_size" { type = number, default = 1 }
variable "eks_max_size" { type = number, default = 3 }
