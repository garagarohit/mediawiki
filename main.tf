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
      "sudo dnf module reset php",
      "sudo dnf install -y httpd php php-mysqlnd php-gd php-xml mariadb-server mariadb php-mbstring php-json mod_ssl php-intl php-apcu",
      "sudo yum install -y wget",
      "sudo yum install -y firewalld",
      "sudo systemctl enable firewalld",
      "sudo restart",
      "sudo systemctl enable mariadb",
      "mysql_secure_installation",
      "mysql -u root -p",
      "sudo mysql -e 'CREATE DATABASE mediawiki_db;'",
      "sudo mysql -e 'CREATE USER 'wiki'@'localhost' IDENTIFIED BY 'THISpasswordSHOULDbeCHANGED';'",
      "sudo mysql -e 'GRANT ALL PRIVILEGES ON mediawiki_db.* TO 'wiki'@'localhost';'",
      "sudo mysql -e 'FLUSH PRIVILEGES;'",
      "sudo mysql -e 'SHOW DATABASES;'",
      "sudo mysql -e 'SHOW GRANTS FOR 'wiki'@'localhost';'",
      "sudo mysql -e 'exit'",
      "sudo systemctl enable mariadb",
      "sudo systemctl enable httpd",
      " cd home/ec2-user",
      "sudo wget https://releases.wikimedia.org/mediawiki/1.41/mediawiki-1.41.0.tar.gz",
      "sudo wget https://releases.wikimedia.org/mediawiki/1.41/mediawiki-1.41.0.tar.gz.sig",
      "gpg --verify mediawiki-1.41.0.tar.gz.sig mediawiki-1.41.0.tar.gz",
      "cd /var/www",
      "sudo tar -zxvf mediawiki-1.41.0.tar.gz",
      "ln -s mediawiki-1.41.0/ mediawiki",
      "chown -R apache:apache /var/www/html/mediawiki/",
      "sudo service httpd restart",
      "sudo firewall-cmd --permanent --zone=public --add-service=http",
      "sudo firewall-cmd --permanent --zone=public --add-service=https",
      "sudo systemctl restart firewalld",
      "getenforce",
      "sudo restorecon -FR /var/www/mediawiki-1.41.0/",
      "sudo restorecon -FR /var/www/mediawiki",
      "ls -lZ /var/www/"
    ]

    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = file("sai_devops.pem")  # Replace with the path to your private key
      host        = aws_instance.Mediawiki.public_ip
    }
  }
}
output "mediawiki_instance_ip" {
  value = aws_instance.Mediawiki.public_ip
}



