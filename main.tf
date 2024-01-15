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
  provisioner "remote-exec" {
    inline = [
      "sudo yum install -y python3",  # Install Python3 (required by Ansible)
    ]
  }
  provisioner "local-exec" {
    command = <<-EOT
      ansible-playbook -i '${aws_instance.Mediawiki.public_ip},' -u ec2-user -e 'ansible_python_interpreter=/usr/bin/python3' mediawiki-playbook.yaml
    EOT
  }
}



