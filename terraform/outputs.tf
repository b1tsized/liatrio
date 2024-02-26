# VPC Outputs

output "vpc_name" {
  description = "Name of the new VPC"
  value       = module.vpc.name
}

output "vpc_public_cidrs" {
  description = "VPC Public CIDR Blocks"
  value       = module.vpc.public_subnets_cidr_blocks
}

output "vpc_private_cidrs" {
  description = "VPC Private CIDR Blocks"
  value       = module.vpc.private_subnets_cidr_blocks
}

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