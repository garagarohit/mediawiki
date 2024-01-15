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

data "aws_ami" "mediawiki" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "architecture"
    values = ["arm64"]
  }
  filter {
    name   = "ami"
    values = ["al2023-ami-2024*"]
  }
}

resource "aws_instance" "Mediawiki" {
  ami           = data.aws_ami.mediawiki.id
  instance_type = "t2.micro"
  key_name = "sai_devops"

  tags = {
    Name = "Mediawiki"
  }
  provisioner "local-exec" {
    command = "chmod 600 sai_devops.pem"
  }
#Running ansible from 
  provisioner "local-exec" {
        command = "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -u centos --private-key ./sai_devops.pem -i '${aws_instance.Mediawiki.public_ip},' mediawiki-playbook.yaml"
     }
}


