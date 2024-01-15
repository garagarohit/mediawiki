terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "ap-south-1"
}

resource "aws_instance" "Mediawiki" {
  ami           = "ami-04708942c263d8190"
  instance_type = "t2.micro"
  key_name = "sai_devops"
  user_data = file("mediawiki.sh")

  tags = {
    Name = "Mediawiki"
  }
}



