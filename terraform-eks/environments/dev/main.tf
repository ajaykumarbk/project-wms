terraform {
  backend "s3" {
    bucket         = "your-terraform-state-bucket"
    key            = "dev/eks/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-state-lock"
  }
}

provider "aws" {
  region = var.aws_region
}

data "aws_caller_identity" "current" {}

locals {
  cluster_name = "${var.cluster_name}-${var.environment}"
  account_id   = data.aws_caller_identity.current.account_id
}

module "networking" {
  source = "../../modules/networking"

  environment        = var.environment
  cluster_name       = local.cluster_name
  vpc_cidr           = var.vpc_cidr
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  single_nat_gateway = var.single_nat_gateway
}

module "eks" {
  source = "../../modules/eks"

  environment         = var.environment
  cluster_name        = local.cluster_name
  cluster_version     = var.cluster_version
  vpc_id              = module.networking.vpc_id
  subnet_ids          = module.networking.public_subnet_ids
  private_subnet_ids  = module.networking.private_subnet_ids
  
  endpoint_private_access = var.endpoint_private_access
  endpoint_public_access  = var.endpoint_public_access
  cluster_log_types       = var.cluster_log_types
  
  node_instance_types = var.node_instance_types
  node_desired_size   = var.node_desired_size
  node_min_size       = var.node_min_size
  node_max_size       = var.node_max_size
  
  ssh_key_name = var.ssh_key_name
}

module "addons" {
  source = "../../modules/addons"

  cluster_name      = module.eks.cluster_name
  oidc_provider_arn = module.eks.cluster_oidc_provider_arn
  oidc_provider_url = module.eks.cluster_oidc_issuer_url

  # Add-on enable flags
  enable_vpc_cni      = true
  enable_coredns      = true
  enable_kube_proxy   = true
  enable_ebs_csi_driver = true

  # Add-on versions
  vpc_cni_version      = var.vpc_cni_version
  coredns_version      = var.coredns_version
  kube_proxy_version   = var.kube_proxy_version
  ebs_csi_driver_version = var.ebs_csi_driver_version

  # IRSA roles
  create_vpc_cni_iam_role    = true
  create_ebs_csi_iam_role    = true

  # Configurations
  coredns_config = {
    replicaCount = 2
    resources = {
      limits = {
        cpu    = "100m"
        memory = "150Mi"
      }
      requests = {
        cpu    = "100m"
        memory = "150Mi"
      }
    }
  }

  ebs_csi_config = {
    defaultStorageClass = {
      enabled = true
    }
  }

  tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}