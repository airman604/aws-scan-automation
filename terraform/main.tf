terraform {
  required_providers {
    # deploying resources to AWS
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }

    # building container image for scanner Lambda
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
data "aws_ecr_authorization_token" "token" {}

locals {
  account_id = data.aws_caller_identity.current.account_id
  region     = data.aws_region.current.name
}

provider "docker" {
  # login to ECR so we can push the scanner image
  registry_auth {
    address  = format("%v.dkr.ecr.%v.amazonaws.com", local.account_id, local.region)
    username = data.aws_ecr_authorization_token.token.user_name
    password = data.aws_ecr_authorization_token.token.password
  }
}

locals {
  s3_prefix = "scout-reports"
}