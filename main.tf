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
  provisioner "remote-exec" {
    inline = [
      "sudo yum install -y httpd php php-mysqlnd php-xml php-intl php-gd php-mbstring php-json php-apcu php-pecl-apcu php-opcache mariadb-server wget",
      "sudo systemctl start httpd",
      "sudo systemctl enable httpd",
      "sudo systemctl start mariadb",
      "sudo systemctl enable mariadb",
      "sudo mysql -e 'CREATE DATABASE mediawiki_db;'",
      "sudo mysql -e 'CREATE USER mediawiki_user@localhost IDENTIFIED BY \"your-password\";'",
      "sudo mysql -e 'GRANT ALL PRIVILEGES ON mediawiki_db.* TO mediawiki_user@localhost;'",
      "sudo mysql -e 'FLUSH PRIVILEGES;'",
      "sudo mysql_secure_installation < /tmp/mysql_secure_installation_input.txt",
      "wget -P /tmp https://releases.wikimedia.org/mediawiki/1.37.1/mediawiki-1.37.1.tar.gz",
      "tar -zxvf /tmp/mediawiki-1.37.1.tar.gz -C /var/www/html/",
      "sudo chown -R apache:apache /var/www/html/mediawiki/",
      "sudo setsebool -P httpd_can_network_connect 1 || true"
    ]

    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = file("sai_devops.pem")  # Replace with the path to your private key
      host        = aws_instance.Mediawiki.public_ip
    }
  }
}



