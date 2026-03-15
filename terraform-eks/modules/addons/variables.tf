variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
}

variable "oidc_provider_arn" {
  description = "OIDC provider ARN"
  type        = string
  default     = null
}

variable "oidc_provider_url" {
  description = "OIDC provider URL"
  type        = string
  default     = null
}

# Add-on enable flags
variable "enable_vpc_cni" {
  description = "Enable VPC CNI add-on"
  type        = bool
  default     = true
}

variable "enable_coredns" {
  description = "Enable CoreDNS add-on"
  type        = bool
  default     = true
}

variable "enable_kube_proxy" {
  description = "Enable kube-proxy add-on"
  type        = bool
  default     = true
}

variable "enable_ebs_csi_driver" {
  description = "Enable EBS CSI driver add-on"
  type        = bool
  default     = true
}

# Add-on versions
variable "vpc_cni_version" {
  description = "VPC CNI add-on version"
  type        = string
  default     = null
}

variable "coredns_version" {
  description = "CoreDNS add-on version"
  type        = string
  default     = null
}

variable "kube_proxy_version" {
  description = "kube-proxy add-on version"
  type        = string
  default     = null
}

variable "ebs_csi_driver_version" {
  description = "EBS CSI driver add-on version"
  type        = string
  default     = null
}

# Service account roles for IRSA
variable "vpc_cni_service_account_role_arn" {
  description = "IAM role ARN for VPC CNI service account"
  type        = string
  default     = null
}

variable "ebs_csi_service_account_role_arn" {
  description = "IAM role ARN for EBS CSI driver service account"
  type        = string
  default     = null
}

# IAM role creation flags
variable "create_vpc_cni_iam_role" {
  description = "Create IAM role for VPC CNI"
  type        = bool
  default     = false
}

variable "create_ebs_csi_iam_role" {
  description = "Create IAM role for EBS CSI driver"
  type        = bool
  default     = false
}

# Add-on configurations
variable "vpc_cni_config" {
  description = "Configuration values for VPC CNI"
  type        = any
  default     = null
}

variable "coredns_config" {
  description = "Configuration values for CoreDNS"
  type        = any
  default     = {
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
}

variable "kube_proxy_config" {
  description = "Configuration values for kube-proxy"
  type        = any
  default     = null
}

variable "ebs_csi_config" {
  description = "Configuration values for EBS CSI driver"
  type        = any
  default     = {
    defaultStorageClass = {
      enabled = true
    }
  }
}

variable "additional_addons" {
  description = "Additional EKS add-ons to install"
  type = map(object({
    version                   = optional(string)
    service_account_role_arn  = optional(string)
    config                    = optional(any)
  }))
  default = {}
}

# General settings
variable "resolve_conflicts" {
  description = "Resolution strategy for add-on conflicts (OVERWRITE, NONE, PRESERVE)"
  type        = string
  default     = "OVERWRITE"
}

variable "tags" {
  description = "Tags to apply to add-on resources"
  type        = map(string)
  default     = {}
}