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
  ami           = "ami-04e914639d0cca79a"
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
        command = "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -u centos --private-key ./sai_devops.pem -i '${aws_instance.myec2instances.public_ip},' mediawiki-playbook.yaml"
     }
}


