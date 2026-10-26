project_id             = "m1909523"
region                 = "europe-west2"
zone                   = "europe-west2-a"
environment            = "dev"
registry_repository_id = "sneak"
network_name           = "sneak-vpc"
subnetwork_name        = "sneak-dev-subnet"
master_ipv4_cidr_block = "10.40.0.0/28"

release_channel     = "REGULAR"
deletion_protection = false
spot                = true
min_nodes           = 1
max_nodes           = 2
