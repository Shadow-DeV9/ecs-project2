terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }

  backend "s3" {
    bucket       = "bankai-tensa-zangetsu19"
    key          = "terraform.tfstate"
    region       = "eu-north-1"
    use_lockfile = true
  }

}
provider "aws" {
  region = "eu-north-1"
}
