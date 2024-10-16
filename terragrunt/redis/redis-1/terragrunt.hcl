locals {
  account_vars = try(read_terragrunt_config(find_in_parent_folders("account.hcl")).locals, null)

  # HELM VARS
  namespace            = "redis"
  name                 = "redis"
  chart                = "redis"
  repository           = "https://charts.bitnami.com/bitnami"
  deploy               = true
  version              = "20.1.7"
  create_namespace     = true
}

dependency "eks_cluster" {
  config_path = "../../kubernetes/cluster-1"
}

terraform {
  source = "../../../terraform-modules/helm/release"
}

include {
  path = find_in_parent_folders()
}

include kubernetes {
  path = find_in_parent_folders("kubernetes.hcl")
}

inputs = {
    namespace  = local.namespace
    repository = local.repository

    app = {
        name             = local.name
        chart            = local.chart
        deploy           = local.deploy
        version          = local.version
        force_update     = true
        create_namespace = local.create_namespace
    }

    values = ["${file("values.yaml")}"]
}
