terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.95.0"
    }
  }
  backend "s3" {
    bucket         = "parthu-tf-remote-state"
    key            = "expense-dev-eks-eks" #you should have unique key with-in the bucket, same key should not be used in other repos
    region         = "us-east-1"
    dynamodb_table = "parthu-state-locking"
  }
}


provider "aws" {
  # Configuration options
  region = "us-east-1"
}
