terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {}
}

# 1. Management Account Provider (Runs as your local IAM user)
provider "aws" {
  profile = "terraform_user"
  region  = "us-east-1"
}

# 2. Governance Account Provider (Automatically assumes the role you just tested)
provider "aws" {
  alias   = "iam_governance"
  profile = "terraform_user"
  region  = "us-east-1"

  assume_role {
    role_arn     = "arn:aws:iam::939005125934:role/OrganizationAccountAccessRole"
    session_name = "TerraformGovernanceSession"
  }
}