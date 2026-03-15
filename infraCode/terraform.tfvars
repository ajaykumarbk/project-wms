aws_region          = "us-east-1"
cluster_name        = "prod-lab-cluster"
cluster_version     = "1.31"

node_instance_types = ["t3.medium"]
node_desired_size   = 3
node_min_size       = 3
node_max_size       = 6

# Optional: Add your SSH key if needed
# ssh_key_name      = "your-key-pair-name"