locals {
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl")).locals
  aws_profile  = "my-aws-profile"
}



generate "kubernetes_provider" {
  path      = "kubernetes_provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
provider "kubernetes" {
  host                   = "${dependency.eks_cluster.outputs.cluster_endpoint}"
  cluster_ca_certificate = <<EOC
${base64decode(dependency.eks_cluster.outputs.cluster_certificate_authority_data)}
EOC

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args        = ["eks", "get-token", "--profile", ${local.aws_profile}, "--cluster-name", "${dependency.eks_cluster.outputs.cluster_name}"]
  }
}

EOF
}

generate "helm_provider" {
  path      = "helm_provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
provider "helm" {
  kubernetes {
    host                   = "${dependency.eks_cluster.outputs.cluster_endpoint}"
    cluster_ca_certificate = <<EOC
${base64decode(dependency.eks_cluster.outputs.cluster_certificate_authority_data)}
EOC

    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      args        = ["eks", "get-token", "--profile", ${local.aws_profile}, "--cluster-name", "${dependency.eks_cluster.outputs.cluster_name}"]
    }
  }
}
EOF
}

generate "kubectl_provider" {
  path      = "kubectl_provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
provider "kubectl" {
  host                   = "${dependency.eks_cluster.outputs.cluster_endpoint}"
  cluster_ca_certificate = <<EOC
${base64decode(dependency.eks_cluster.outputs.cluster_certificate_authority_data)}
EOC
  load_config_file       = false

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args        = ["eks", "get-token", "--profile", ${local.aws_profile}, "--cluster-name", "${dependency.eks_cluster.outputs.cluster_name}"]
  }
}
EOF
}

generate "kubectl_versions" {
  path      = "kubectl_version_override.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
terraform {
  required_providers {
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.11.2"
    }
  }
}
EOF
}
