# Sneak Platform Engineering Project

A portfolio project demonstrating repeatable cloud infrastructure, GKE, Terraform state management, workload identity, and CI/CD using Google Cloud and GitHub Actions.

> **Status:** infrastructure foundation is in progress. The Terraform validation workflow and example application are included here; run the checks and review the plan in your own GCP project before applying.

## Architecture

- **Shared foundation:** required Google APIs, a dedicated VPC and per-environment subnets, Artifact Registry, GitHub Actions Workload Identity Federation (OIDC), and a dedicated deployer service account.
- **Environment roots:** independent Terraform state prefixes and GKE clusters for development and production.
- **CI:** pull requests run Terraform formatting/validation and a repository security scan.
- **Application delivery:** GitHub Actions builds an image, publishes it to Artifact Registry using OIDC, and deploys Kubernetes manifests to GKE. Image tags use the commit SHA.

## Repository layout

```text
terraform/
  environments/
    shared/  # shared cloud foundation; apply first
    dev/     # development GKE cluster
    prod/    # production GKE cluster
  modules/gcp/gke/
    # reusable GKE cluster and node-pool module
app/         # minimal example application
k8s/         # Kubernetes deployment and service
.github/workflows/
  terraform-validate.yml
  deploy.yml
```

## Prerequisites

- Terraform >= 1.10 and the Google provider version constrained in the root modules.
- A GCP project with billing enabled and permission to enable APIs, create IAM identities, networking, Artifact Registry and GKE resources.
- Google Cloud CLI for local authentication, or the configured GitHub Actions OIDC trust for CI.
- Docker and kubectl for application deployment.

## State and apply order

The GCS backend bucket must exist before Terraform initialization. This repository expects the bucket `sneak-tfstate-m1909523`; change the backend configuration if your bucket name differs. Protect the bucket with uniform bucket-level access, public access prevention, object versioning, and narrowly scoped IAM.

Apply the roots in this order because the environment roots consume shared infrastructure:

1. `terraform/environments/shared`
2. `terraform/environments/dev`
3. `terraform/environments/prod`

Run commands from each root directory:

```bash
terraform init
terraform fmt -check -recursive
terraform validate
terraform plan
```

**State migration warning:** the previous versions of `shared` and `prod` declared overlapping API, Artifact Registry and GitHub identity resources. If either root has already been applied, inspect both states and plans before applying this branch. Do not blindly apply a plan that proposes deleting shared resources from the old production state. Back up state first and migrate/import ownership deliberately. This branch does not perform a state migration automatically.

Review every plan before applying. Production resources have deletion protection enabled; changes that replace protected resources require an explicit operational decision. Do not disable deletion protection simply to make a plan succeed.

## GitHub Actions configuration

The shared root configures Workload Identity Federation and a dedicated deployer service account. The trust condition is scoped to the configured repository. The deployment workflow expects these **GitHub repository or production-environment variables**:

- `GCP_WORKLOAD_IDENTITY_PROVIDER`: the full `wif_provider` output from the shared root.
- `GCP_SERVICE_ACCOUNT`: the `deployer_sa` output.
- `GCP_PROJECT_ID`: GCP project ID.
- `GCP_REGION`: Artifact Registry region, e.g. `europe-west2`.
- `AR_REPOSITORY`: Artifact Registry repository ID, e.g. `sneak`.
- `GKE_CLUSTER`: cluster name, e.g. `sneak-prod`.
- `GKE_LOCATION`: cluster zone, e.g. `europe-west2-b`.

Configure a protected GitHub Environment named `production` with required reviewers before enabling production deployments. The current deployer role is a portfolio baseline; review it against least privilege and configure appropriate Kubernetes RBAC.

## Network and workload caveats

GKE nodes have private IPs, while the control-plane endpoint is public so a hosted GitHub runner can reach it. Authentication is still required, but before production use restrict control-plane access or use a private endpoint with a runner that has private network connectivity. Private nodes do not have general internet egress in this design; add and configure Cloud NAT if workloads need to reach public internet services.

Development is configured for lower-cost Spot nodes and a regular release channel. Production uses non-Spot nodes, deletion protection and the regular release channel. These are lab defaults, not a claim that the cluster is fully production-hardened.

Before real workloads, review network policies, secret management, backup and restore, availability requirements, cost budgets, and workload security controls.

## Security notes

- Terraform state and plan files are ignored by Git.
- Commit `terraform.tfvars` only for non-secret configuration.
- Never commit credentials, state files, generated plans or service-account keys.
- Workflows use OIDC instead of long-lived service-account keys and pin third-party actions to commit SHAs.
- Validate the actual Terraform plan and CI run; code in a repository is not proof of a successful deployment.
