provider "aws" {
  region  = local.workspace.region
  assume_role {
    role_arn = "arn:aws:iam::${local.workspace.aws.account_id}:role/${local.workspace.aws.role}"
  }
}

provider "aws" {
  alias   = "us-east-1"
  region  = "us-east-1"
  assume_role {
    role_arn = "arn:aws:iam::${local.workspace.aws.account_id}:role/${local.workspace.aws.role}"
  }
}

terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      # version = "3.39.0"
    }
    random = {
      source = "hashicorp/random"
    }
    template = {
      source = "hashicorp/template"
    }
  }
}

# To fix errors like:
# - Failed to instantiate provider "registry.terraform.io/-/aws" to obtain schema: unknown provider "registry.terraform.io/-/aws"

# run a "make shell" and the commands below:
# terraform state replace-provider registry.terraform.io/-/aws registry.terraform.io/hashicorp/aws
# terraform state replace-provider registry.terraform.io/-/random registry.terraform.io/hashicorp/random
# terraform state replace-provider registry.terraform.io/-/template registry.terraform.io/hashicorp/template

locals {
  env       = yamldecode(file("${path.module}/one.yaml"))
  workspace = local.env["workspaces"][terraform.workspace]
  common    = local.env["common"]
}