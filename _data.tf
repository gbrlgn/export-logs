data "aws_vpc" "selected" {
  filter {
    name   = "tag:Name"
    values = ["${local.workspace.account_name}-VPC"]
  }
}

data "aws_iam_account_alias" "current" {}
data "aws_region" "current" {}
