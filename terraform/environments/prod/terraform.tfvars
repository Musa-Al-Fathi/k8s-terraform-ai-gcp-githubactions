project_id             = "m1909523"
region                 = "europe-west2"
zone                   = "europe-west2-b"
environment            = "prod"
registry_repository_id = "sneak"
network_name           = "sneak-vpc"
subnetwork_name        = "sneak-prod-subnet"
master_ipv4_cidr_block = "10.40.0.16/28"

master_authorized_cidr_blocks = [
  {
    cidr_block   = "192.0.2.0/24"
    display_name = "REPLACE_WITH_TRUSTED_RUNNER_OR_ADMIN_EGRESS"
  }
]

release_channel     = "REGULAR"
deletion_protection = true
spot                = false
min_nodes           = 1
max_nodes           = 3
