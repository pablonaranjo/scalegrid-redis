resource "aws_eks_addon" "this" {
  cluster_name                = var.eks_cluster_name
  addon_name                  = var.name
  addon_version               = var.addon_version
  resolve_conflicts_on_update = var.resolve_conflicts_on_update
}