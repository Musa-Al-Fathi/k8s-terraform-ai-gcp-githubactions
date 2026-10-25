output "cluster_name" {
  value = google_container_cluster.main.name
}

output "get_credentials" {
  value = "gcloud container clusters get-credentials ${google_container_cluster.main.name} --zone ${var.zone} --project ${var.project_id}"
}

output "node_service_account_email" {
  value = google_service_account.nodes.email
}