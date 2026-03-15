aws_region               = "us-east-1"
environment              = "prod"
cluster_name             = "prod-lab-cluster"  # Matches your eksctl config
cluster_version          = "1.29"

vpc_cidr                 = "10.1.0.0/16"
public_subnet_cidrs      = ["10.1.1.0/24", "10.1.2.0/24", "10.1.3.0/24"]
private_subnet_cidrs     = ["10.1.10.0/24", "10.1.11.0/24", "10.1.12.0/24"]
single_nat_gateway       = false

endpoint_private_access  = true
endpoint_public_access   = false
cluster_log_types        = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

node_instance_types      = ["t3.medium"]
node_desired_size        = 3
node_min_size            = 3
node_max_size            = 6

# Add-on versions
vpc_cni_version          = "v1.18.3-eksbuild.1"
coredns_version          = "v1.11.1-eksbuild.4"
kube_proxy_version       = "v1.29.0-eksbuild.1"
ebs_csi_driver_version   = "v1.29.1-eksbuild.1"