# Locals
locals {
  cluster_name = "liatrio-eks-${random_pet.suffix.id}"
  vpc_name     = "liatrio-eks-vpc-${random_pet.suffix.id}"
  ecr_repo     = "liatrio_${random_pet.suffix.id}"
  suffix       = random_pet.suffix.id
}

resource "random_pet" "suffix" {
  length = 1
}

# VPC Creation Module
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.0.0"

  name = local.vpc_name

  cidr = "10.0.0.0/16"
  azs  = slice(data.aws_availability_zones.available.names, 0, 3)

  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]

  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true

  public_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                      = 1
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"             = 1
  }
}

# EKS Creation Module
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "19.15.3"

  cluster_name    = local.cluster_name
  cluster_version = "1.29"

  vpc_id                         = module.vpc.vpc_id
  subnet_ids                     = module.vpc.private_subnets
  cluster_endpoint_public_access = true

  eks_managed_node_group_defaults = {
    ami_type = "AL2_x86_64"

  }

  eks_managed_node_groups = {
    one = {
      name = "eks-${local.suffix}-gp1"

      instance_types = ["t3.small"]

      min_size     = 1
      max_size     = 3
      desired_size = 2
    }

    two = {
      name = "eks-${local.suffix}-gp2"

      instance_types = ["t3.small"]

      min_size     = 1
      max_size     = 2
      desired_size = 1
    }
  }
}

# ECR Build
module "lambda_docker-build" {
  source          = "terraform-aws-modules/lambda/aws//modules/docker-build"
  version         = "7.2.1"
  create_ecr_repo = true
  ecr_repo        = local.ecr_repo
  image_tag       = "latest"
  source_path     = "../docker"
}

# Validate Container Running
resource "time_sleep" "wait_2_minutes" {
  depends_on = [kubernetes_service.liatrio_go]

  create_duration = "2m"
}

resource "null_resource" "container_is_running" {
  triggers = {
    k8s_service_lb = kubernetes_service.liatrio_go.status.0.load_balancer.0.ingress.0.hostname
  }

  provisioner "local-exec" {
    command     = "scripts/healthcheck.sh $URL"
    interpreter = ["/bin/bash", "-c"]
    environment = {
      URL = "${kubernetes_service.liatrio_go.status.0.load_balancer.0.ingress.0.hostname}/healthcheck"
    }

  }

  depends_on = [time_sleep.wait_2_minutes]
}