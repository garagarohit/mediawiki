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


  tags = {
    Name = "Mediawiki"
  }
  provisioner "local-exec" {
    command = "chmod 600 sai_devops.pem"
  }
  provisioner "local-exec" {
        command = "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -u root --private-key ./sai_devops.pem -i '${aws_instance.Mediawiki.public_ip},' mediawiki-playbook.yaml"
     }
}


