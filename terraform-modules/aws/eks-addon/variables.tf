variable "name" {
  type = string
  description = "Addon Name"
}

variable "eks_cluster_name" {
  type = string
  description = "EKS Cluster Name"
}

variable "addon_version" {
  type = string
  description = "Addon Version"
}

variable "resolve_conflicts_on_update" {
  type = string
  description = "What to do in case of conflicts on update"
  default = "PRESERVE"
}
