provider "aws" {
  region = "us-east-1"
  #profile = "eks_master"        ---->>> So, what this does is, it specify which credential that will create the cluster
  # This ("eks_master") is among my list of credentials in aws or my localsytem but right now am using my default credentials ... 
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws" # Corrected provider source
      version = "~> 3.0"
    }
  }
}

