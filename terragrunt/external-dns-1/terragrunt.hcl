locals {
  account_vars    = try(read_terragrunt_config(find_in_parent_folders("account.hcl")).locals, null)

  # HELM VARS
  namespace = "external-dns"
  name = "external-dns"
  chart = "external-dns"
  service_account_name = "external-dns"
  repository = "https://kubernetes-sigs.github.io/external-dns/"
  deploy = true
  create_namespace = true
  version = "1.15.0"

  # Route53
  domains = ["scalegrid-example.com"]
  aws_serviceaccount_role = "external-dns"
}

dependency "eks_cluster" {
  config_path = "../kubernetes/cluster-1"
}

terraform {
  source = "../../terraform-modules/helm/release"
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

    set = [
        {
            name = "aws.region"
            value = "us-east-1"
        },
        {
            name = "policy"
            value = "upsert-only"
        },
        {
            name = "provider"
            value = "aws"
        },
        {
            name = "registry"
            value = "txt"
        },
        {
            name = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
            value = "arn:aws:iam::${local.account_vars.aws_account_id}:role/${local.aws_serviceaccount_role}"
        },
        {
            name = "serviceAccount.create"
            value = true
        },
        {
            name = "serviceAccount.name"
            value = local.service_account_name
        },
        {
            name = "txtOwnerId"
            value = "scalegrid"
        }
    ]
    set_list = [
        {
            name = "domainFilters"
            value = local.domains
        }
    ]
}
