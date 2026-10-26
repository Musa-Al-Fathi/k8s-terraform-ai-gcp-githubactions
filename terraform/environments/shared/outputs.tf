output "wif_provider" {
  value       = google_iam_workload_identity_pool_provider.github.name
  description = "Workload Identity Federation provider resource name for GitHub Actions."
}

output "deployer_sa" {
  value       = google_service_account.github_deployer.email
  description = "Dedicated service account used by GitHub Actions."
}

output "registry_url" {
  value       = "${var.region}-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.sneak.repository_id}"
  description = "Artifact Registry Docker repository URL."
}

output "network_name" {
  value = google_compute_network.platform.name
}

output "subnet_names" {
  value = { for name, subnet in google_compute_subnetwork.environment : name => subnet.name }
}