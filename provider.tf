terraform{
    required_version = ">=1.5.0"
    required_providers {
      aws={
        source = "harshicorps/aws"
        version = "~> 5.0"
      }
    }
}

provider "aws" {
  region="us-east-1"
}