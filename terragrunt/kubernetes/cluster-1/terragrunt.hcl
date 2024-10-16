locals {
  account_vars    = try(read_terragrunt_config(find_in_parent_folders("account.hcl")).locals, null)
  cluster_name    = "cluster-1"
  cluster_version = "1.30"
  node_group_name = "eks-node-${local.cluster_name}"
  vpc_id          = local.account_vars.vpc_id
  subnet_ids      = local.account_vars.subnet_ids
}

terraform {
  source = "tfr:///terraform-aws-modules/eks/aws?version=20.24.0"
}

include {
  path = find_in_parent_folders()
}

inputs = {
  cluster_name                   = local.cluster_name
  cluster_version                = local.cluster_version
  cluster_endpoint_public_access = true
  vpc_id                         = local.vpc_id
  subnet_ids                     = local.subnet_ids
  kms_key_administrators         = ["arn:aws:iam::${local.account_vars.aws_account_id}:root"]
  bootstrap_self_managed_addons  = true

  enable_cluster_creator_admin_permissions = true


  node_security_group_additional_rules = {
      allow_redis = {
        description = "Allow to connect to Redis from other EKS Cluster"
        protocol    = "TCP"
        cidr_blocks = ["10.150.0.0/16"]
        from_port   = 6379
        to_port     = 6379
        type        = "ingress"
      }
  }

  eks_managed_node_group_defaults = {
    ami_type                   = "AL2_x86_64"
    instance_types             = ["t3.small"]
    iam_role_attach_cni_policy = true
  }

  eks_managed_node_groups = {
    (local.node_group_name) = {
      iam_role_additional_policies = {
          AmazonEC2FullAccess = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
      }
      use_custom_launch_template = true
      iam_role_name              = "${local.cluster_name}-eks-node-role"

      ami_type     = "BOTTLEROCKET_x86_64"
      platform     = "bottlerocket"
      disk_size    = 10
      min_size     = 1
      max_size     = 2
      desired_size = 1
    }
  }
}