# Sneak Platform Engineering Project

A portfolio project demonstrating repeatable cloud infrastructure, GKE, Terraform state management, workload identity, and CI/CD using Google Cloud and GitHub Actions.

> **Status:** infrastructure foundation is in progress. The Terraform validation workflow and example application are included here; run the checks and review the plan in your own GCP project before applying.

## Architecture

- **Shared foundation:** required Google APIs, a dedicated VPC and per-environment subnets, Artifact Registry, GitHub Actions Workload Identity Federation (OIDC), and a dedicated deployer service account.
- **Environment roots:** independent Terraform state prefixes and GKE clusters for development and production.
- **CI:** pull requests run Terraform formatting/validation and a repository security scan.
- **Application delivery:** GitHub Actions builds a small container image, publishes it to Artifact Registry using OIDC, and deploys Kubernetes manifests to GKE.

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

Review every plan before applying. Production resources have deletion protection enabled; changes that replace protected resources require an explicit operational decision. Do not disable deletion protection simply to make a plan succeed.

## GitHub Actions authentication

The shared root configures Workload Identity Federation and a dedicated deployer service account. The trust condition is scoped to the configured repository. Configure the workflow's WIF provider and service-account values from the shared Terraform outputs; do not store service-account JSON keys or other cloud credentials in GitHub secrets.

For production, configure a protected GitHub Environment with required reviewers and environment-scoped variables. Review IAM roles against the exact permissions the workflow needs.

## Environment choices

Development is configured for lower-cost Spot nodes and a faster release channel for experimentation. Production uses non-Spot nodes, deletion protection and a more conservative release channel. These are lab defaults, not a claim that the cluster is fully production-hardened.

Before using this for real workloads, review private cluster/API endpoint access, Cloud NAT/egress, network policies, secret management, backup and restore, availability requirements, cost budgets, and workload security controls.

## Security notes

- Terraform state and plan files are ignored by Git.
- Commit `terraform.tfvars` only for non-secret configuration.
- Never commit credentials, state files, generated plans or service-account keys.
- CI should use least privilege, immutable image tags, pinned third-party actions, and protected production approvals.
- Validate the actual Terraform plan and CI run; code in a repository is not proof of a successful deployment.
