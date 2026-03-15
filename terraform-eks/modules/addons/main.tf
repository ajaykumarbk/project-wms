# Data source to get EKS cluster info
data "aws_eks_cluster" "cluster" {
  name = var.cluster_name
}

# VPC CNI Add-on
resource "aws_eks_addon" "vpc_cni" {
  count = var.enable_vpc_cni ? 1 : 0

  cluster_name                = var.cluster_name
  addon_name                  = "vpc-cni"
  addon_version               = var.vpc_cni_version
  service_account_role_arn    = var.vpc_cni_service_account_role_arn
  resolve_conflicts_on_create = var.resolve_conflicts
  resolve_conflicts_on_update = var.resolve_conflicts
  
  configuration_values = var.vpc_cni_config != null ? jsonencode(var.vpc_cni_config) : null

  tags = merge(
    var.tags,
    {
      Name = "${var.cluster_name}-vpc-cni"
    }
  )
}

# CoreDNS Add-on
resource "aws_eks_addon" "coredns" {
  count = var.enable_coredns ? 1 : 0

  cluster_name                = var.cluster_name
  addon_name                  = "coredns"
  addon_version               = var.coredns_version
  resolve_conflicts_on_create = var.resolve_conflicts
  resolve_conflicts_on_update = var.resolve_conflicts
  
  configuration_values = var.coredns_config != null ? jsonencode(var.coredns_config) : null

  tags = merge(
    var.tags,
    {
      Name = "${var.cluster_name}-coredns"
    }
  )
}

# kube-proxy Add-on
resource "aws_eks_addon" "kube_proxy" {
  count = var.enable_kube_proxy ? 1 : 0

  cluster_name                = var.cluster_name
  addon_name                  = "kube-proxy"
  addon_version               = var.kube_proxy_version
  resolve_conflicts_on_create = var.resolve_conflicts
  resolve_conflicts_on_update = var.resolve_conflicts
  
  configuration_values = var.kube_proxy_config != null ? jsonencode(var.kube_proxy_config) : null

  tags = merge(
    var.tags,
    {
      Name = "${var.cluster_name}-kube-proxy"
    }
  )
}

# EBS CSI Driver Add-on
resource "aws_eks_addon" "ebs_csi" {
  count = var.enable_ebs_csi_driver ? 1 : 0

  cluster_name                = var.cluster_name
  addon_name                  = "aws-ebs-csi-driver"
  addon_version               = var.ebs_csi_driver_version
  service_account_role_arn    = var.ebs_csi_service_account_role_arn
  resolve_conflicts_on_create = var.resolve_conflicts
  resolve_conflicts_on_update = var.resolve_conflicts
  
  configuration_values = var.ebs_csi_config != null ? jsonencode(var.ebs_csi_config) : null

  tags = merge(
    var.tags,
    {
      Name = "${var.cluster_name}-ebs-csi-driver"
    }
  )
}

# Additional EKS Add-ons (Optional)
resource "aws_eks_addon" "additional" {
  for_each = var.additional_addons

  cluster_name                = var.cluster_name
  addon_name                  = each.key
  addon_version               = each.value.version
  service_account_role_arn    = each.value.service_account_role_arn
  resolve_conflicts_on_create = var.resolve_conflicts
  resolve_conflicts_on_update = var.resolve_conflicts
  
  configuration_values = each.value.config != null ? jsonencode(each.value.config) : null

  tags = merge(
    var.tags,
    {
      Name = "${var.cluster_name}-${each.key}"
    }
  )
}

# IAM Role for EBS CSI Driver (if not provided)
resource "aws_iam_role" "ebs_csi_driver" {
  count = var.enable_ebs_csi_driver && var.create_ebs_csi_iam_role && var.ebs_csi_service_account_role_arn == null ? 1 : 0
  
  name = "${var.cluster_name}-ebs-csi-driver-role"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = var.oidc_provider_arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "${replace(var.oidc_provider_url, "https://", "")}:sub" = "system:serviceaccount:kube-system:ebs-csi-controller-sa"
          }
        }
      }
    ]
  })

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "ebs_csi_driver" {
  count = var.enable_ebs_csi_driver && var.create_ebs_csi_iam_role && var.ebs_csi_service_account_role_arn == null ? 1 : 0
  
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
  role       = aws_iam_role.ebs_csi_driver[0].name
}

# IAM Role for VPC CNI (if not provided)
resource "aws_iam_role" "vpc_cni" {
  count = var.enable_vpc_cni && var.create_vpc_cni_iam_role && var.vpc_cni_service_account_role_arn == null ? 1 : 0
  
  name = "${var.cluster_name}-vpc-cni-role"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = var.oidc_provider_arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "${replace(var.oidc_provider_url, "https://", "")}:sub" = "system:serviceaccount:kube-system:aws-node"
          }
        }
      }
    ]
  })

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "vpc_cni" {
  count = var.enable_vpc_cni && var.create_vpc_cni_iam_role && var.vpc_cni_service_account_role_arn == null ? 1 : 0
  
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.vpc_cni[0].name
}