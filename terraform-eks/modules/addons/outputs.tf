output "vpc_cni_id" {
  description = "VPC CNI add-on ID"
  value       = try(aws_eks_addon.vpc_cni[0].id, null)
}

output "vpc_cni_version" {
  description = "VPC CNI add-on version"
  value       = try(aws_eks_addon.vpc_cni[0].addon_version, null)
}

output "coredns_id" {
  description = "CoreDNS add-on ID"
  value       = try(aws_eks_addon.coredns[0].id, null)
}

output "coredns_version" {
  description = "CoreDNS add-on version"
  value       = try(aws_eks_addon.coredns[0].addon_version, null)
}

output "kube_proxy_id" {
  description = "kube-proxy add-on ID"
  value       = try(aws_eks_addon.kube_proxy[0].id, null)
}

output "kube_proxy_version" {
  description = "kube-proxy add-on version"
  value       = try(aws_eks_addon.kube_proxy[0].addon_version, null)
}

output "ebs_csi_driver_id" {
  description = "EBS CSI driver add-on ID"
  value       = try(aws_eks_addon.ebs_csi[0].id, null)
}

output "ebs_csi_driver_version" {
  description = "EBS CSI driver add-on version"
  value       = try(aws_eks_addon.ebs_csi[0].addon_version, null)
}

output "ebs_csi_iam_role_arn" {
  description = "IAM role ARN for EBS CSI driver"
  value       = try(aws_iam_role.ebs_csi_driver[0].arn, var.ebs_csi_service_account_role_arn)
}

output "vpc_cni_iam_role_arn" {
  description = "IAM role ARN for VPC CNI"
  value       = try(aws_iam_role.vpc_cni[0].arn, var.vpc_cni_service_account_role_arn)
}

output "additional_addon_ids" {
  description = "Map of additional add-on IDs"
  value       = { for k, v in aws_eks_addon.additional : k => v.id }
}