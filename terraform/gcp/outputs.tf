output "cluster_name" { value = google_container_cluster.platform.name }
output "artifact_registry_repository" {
  value = "${var.region}-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.platform.repository_id}"
}
output "get_credentials_command" {
  value = "gcloud container clusters get-credentials ${google_container_cluster.platform.name} --zone ${var.zone} --project ${var.project_id}"
}
