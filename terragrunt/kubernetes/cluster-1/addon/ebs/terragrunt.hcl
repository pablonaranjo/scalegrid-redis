locals {
  account_vars    = try(read_terragrunt_config(find_in_parent_folders("account.hcl")).locals, null)

  # ADDON
  name = "aws-ebs-csi-driver"
  version = "v1.35.0-eksbuild.1"
}

dependency "eks_cluster" {
  config_path = "../../."
}

terraform {
  source = "../../../../../terraform-modules/aws/eks-addon"
}

include {
  path = "../../../../terragrunt.hcl"
}

include kubernetes {
  path = find_in_parent_folders("kubernetes.hcl")
}

inputs = {
  name          = local.name
  addon_version = local.version

  eks_cluster_name = dependency.eks_cluster.outputs.cluster_name
}
