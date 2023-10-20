provider "aws" {
  region = "us-east-1"
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}


data "terraform_remote_state" "network" {
  backend = "local"
  config = {
    path = "../oidc-test/terraform.tfstate"
  }
}
