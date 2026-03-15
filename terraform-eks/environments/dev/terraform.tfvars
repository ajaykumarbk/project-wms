# AWS Configuration
aws_region               = "us-east-1"
environment              = "dev"
cluster_name             = "prod-lab-cluster"  # Matches your eksctl config name
cluster_version          = "1.31"               # Updated to match your eksctl version

# VPC Configuration
vpc_cidr                 = "10.0.0.0/16"
public_subnet_cidrs      = ["10.0.1.0/24", "10.0.2.0/24"]
private_subnet_cidrs     = ["10.0.10.0/24", "10.0.11.0/24"]
single_nat_gateway       = true  # Cost-effective for dev

# API Endpoint Configuration
endpoint_private_access  = false  # Keep simple for dev
endpoint_public_access   = true   # Enable public access for easy management
cluster_log_types        = ["api", "audit", "authenticator"]  # Basic logging for dev

# Node Group Configuration (matching your eksctl config)
node_instance_types      = ["t3.medium"]
node_desired_size        = 2      # desiredCapacity from your config
node_min_size            = 1      # minSize from your config
node_max_size            = 4      # maxSize from your config

# SSH (optional - remove if not needed)
ssh_key_name             = null   # Set to your key pair name if you need SSH access

# Add-on versions for Kubernetes 1.31
vpc_cni_version          = "v1.18.3-eksbuild.1"  # Latest compatible with 1.31
coredns_version          = "v1.11.1-eksbuild.4"  # Latest compatible with 1.31
kube_proxy_version       = "v1.31.0-eksbuild.1"  # Updated for K8s 1.31
ebs_csi_driver_version   = "v1.35.0-eksbuild.1"  # Updated for K8s 1.31