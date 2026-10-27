output "cluster_name" { value = aws_eks_cluster.platform.name }
output "ecr_repository_url" { value = aws_ecr_repository.platform.repository_url }
output "aws_region" { value = var.aws_region }
output "get_credentials_command" {
  value = "aws eks update-kubeconfig --region ${var.aws_region} --name ${aws_eks_cluster.platform.name}"
}
