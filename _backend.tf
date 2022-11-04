terraform {
  backend "s3" {
    bucket         = "galaxpay-terraform-backend"
    key            = "lambda-export-pi"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-lock"
    role_arn       = "arn:aws:iam::024917331266:role/terraform-backend"
  }
}
