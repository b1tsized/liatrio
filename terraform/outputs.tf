# EKS Outputs
output "cluster_endpoint" {
  description = "Endpoint for EKS control plane"
  value       = module.eks.cluster_endpoint
}

output "cluster_security_group_id" {
  description = "Security group ids attached to the cluster control plane"
  value       = module.eks.cluster_security_group_id
}

output "region" {
  description = "AWS region"
  value       = var.aws_region
}

output "cluster_name" {
  description = "Kubernetes Cluster Name"
  value       = module.eks.cluster_name
}

output "cluster_cert_authority" {
  description = "Kubernetes Cluster Certificate Authority"
  value       = module.eks.cluster_certificate_authority_data
  sensitive   = true
}

# ECS Image Outputs
output "image_uri" {
  description = "The ECR image URI for deploying lambda"
  value       = module.lambda_docker-build.image_uri
}

# EKS Service IP
output "liatrio_go_url" {
  value = "http://${kubernetes_service.liatrio_go.status.0.load_balancer.0.ingress.0.hostname}"
}