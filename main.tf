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
#Security Group for our application
resource "aws_security_group" "mysecuritygroup" {
  name = "mysecuritygroup"
  ingress {
    description      = "TLS from VPC"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }
    ingress {
    description      = "TLS from VPC"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }
    ingress {
    description      = "TLS from VPC"
    from_port        = 3306
    to_port          = 3306
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }
    ingress {
    description      = "TLS from VPC"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

    egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }
  tags = {
    Name = "Terraform-SG"
  }
}

resource "aws_instance" "Mediawiki" {
  ami           = "ami-04708942c263d8190"
  instance_type = "t2.micro"
  vpc_security_group_ids = [aws_security_group.mysecuritygroup.id]
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


