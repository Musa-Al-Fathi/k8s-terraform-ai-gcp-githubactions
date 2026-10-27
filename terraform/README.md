# Multi-cloud Kubernetes platform

Three independent Terraform roots provision Kubernetes plus a container registry:

| Root | Kubernetes | Registry |
|---|---|---|
| `terraform/azure` | AKS | Azure Container Registry (ACR) |
| `terraform/aws` | EKS | Amazon ECR |
| `terraform/gcp` | GKE | Artifact Registry (Docker) |

Run Terraform only in the provider directory you intend to use. Applying all three creates three separate environments and incurs three sets of costs.

## Prerequisites

Terraform 1.6+, provider CLI and credentials, and permissions to create networking, Kubernetes, registries and IAM. Prefer OIDC/workload identity in CI. Never commit credentials, local state, kubeconfig files or real `terraform.tfvars`.

## Initialise and validate

```bash
terraform -chdir=terraform/azure init
terraform -chdir=terraform/azure fmt -recursive
terraform -chdir=terraform/azure validate
terraform -chdir=terraform/aws init
terraform -chdir=terraform/aws fmt -recursive
terraform -chdir=terraform/aws validate
terraform -chdir=terraform/gcp init
terraform -chdir=terraform/gcp fmt -recursive
terraform -chdir=terraform/gcp validate
```

Copy the provider's `terraform.tfvars.example` to `terraform.tfvars` and replace all placeholder values. Both AWS and GCP examples use the documentation-only IP `203.0.113.10/32`; replace it with the trusted public egress IP/CIDR used by administrators or runners. Never widen control-plane access to `0.0.0.0/0`.

Then, from the selected provider root, review the plan and apply intentionally:

```bash
terraform plan
terraform apply
```

## Configure kubectl and push images

Use the `get_credentials_command` output after apply.

- **Azure:** `az acr login --name <acr-name>`; tag and push to `<acr-login-server>/<image>:<git-sha>`.
- **AWS:** authenticate with `aws ecr get-login-password --region <region> | docker login --username AWS --password-stdin <account-id>.dkr.ecr.<region>.amazonaws.com`; tag and push to the ECR output URL.
- **GCP:** `gcloud auth configure-docker <region>-docker.pkg.dev`; tag and push to the Artifact Registry output path.

Use immutable image tags (such as a Git commit SHA), not `latest`. AKS receives ACR pull permission; EKS node roles have ECR read permission; GKE node service accounts have Artifact Registry reader permission.

## State, cost and safety

These new roots use local state by default. For team/CI use, configure a separate protected remote backend per root, with state versioning/locking where supported. Do not reuse a state key across clouds.

AWS creates a NAT Gateway, which incurs hourly and data-processing charges. Kubernetes, node pools, load balancers, registries, IP addresses and logs can also cost money. Inspect `terraform plan-destroy` (correct command: `terraform plan -destroy`) before destroying resources.

The previous GCP-specific layout under `terraform/environments` and `terraform/modules` is retained for continuity. Treat `terraform/gcp` as the new standalone GCP root; do not manage the same resources from both layouts. If you already applied the old roots, inspect and migrate/import state deliberately before applying these new roots.

These are practical learning baselines, not a turnkey enterprise landing zone. Production deployments should add environment-specific policy, private connectivity, encryption/key management, workload identity for pods, backups, monitoring/alerts, budgets, policy scanning and tested CI/CD identities. The AWS example uses one NAT Gateway to limit baseline cost; higher availability may warrant one per AZ.
