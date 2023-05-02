terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.64"
    }
  }
}

provider "aws" {
  region = "us-east-1"

  default_tags {
    tags = {
      "Terraform" = "True"
    }
  }
}

