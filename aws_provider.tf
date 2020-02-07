# Specifies the details for the AWS Terraform provider
# https://www.terraform.io/docs/providers/aws/

provider "aws" {
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
  region     = var.aws_region
}

