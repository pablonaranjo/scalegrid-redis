locals {
  account_vars = try(read_terragrunt_config(find_in_parent_folders("account.hcl")).locals, null)
}


generate "provider" {
  path      = "aws-provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
provider "aws" {
  region  = "${local.account_vars.aws_region}"
  profile = "my-aws-profile"
}
EOF
}

remote_state {
  backend = "s3"
  generate = {
    path      = "remote-state.tf"
    if_exists = "overwrite_terragrunt"
  }
  config = {
    bucket         = "terraform-states-${local.account_vars.aws_account_id}"
    profile        = "my-aws-profile"
    region         = "us-east-1"
    key            = "${path_relative_to_include()}/terraform.tfstate"
    encrypt        = false

    skip_bucket_ssencryption = true
    skip_bucket_root_access  = true
    skip_bucket_enforced_tls = true
  }
}