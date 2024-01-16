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
      "sudo module enable -y php",
      "sudo dnf install -y httpd php php-mysqlnd php-gd php-xml mariadb-server mariadb php-mbstring php-json mod_ssl php-intl php-apcu firewalld",
      "sudo yum install -y wget",
      "sudo systemctl enable mariadb",
      "sudo mysql -u root -pwiki -e 'CREATE USER mediawiki_user@localhost IDENTIFIED BY \"wiki\";'",
      "sudo mysql -u root -pwiki -e 'CREATE DATABASE mediawiki_db;'",
      "sudo mysql -u root -pwiki -e 'GRANT ALL PRIVILEGES ON mediawiki_db.* TO mediawiki_user@localhost;'",
      "sudo mysql -u root -pwiki -e 'FLUSH PRIVILEGES;'",
      "sudo systemctl enable mariadb",
      "sudo systemctl enable httpd",
      "mkdir -p home/ec2-user",
      "sudo wget https://releases.wikimedia.org/mediawiki/1.41/mediawiki-1.41.0.tar.gz",
      "sudo wget https://releases.wikimedia.org/mediawiki/1.41/mediawiki-1.41.0.tar.gz.sig",
      "gpg --verify mediawiki-1.41.0.tar.gz.sig mediawiki-1.41.0.tar.gz",
      "cd ../..",
      "cd var/www",
      "sudo tar -zxvf home/ec2-user/mediawiki-1.41.0.tar.gz",
      "sudo ln -s mediawiki-1.41.0/ mediawiki",
      "sudo chown -R apache:apache /var/www/mediawiki/",
      "sudo service httpd restart",
      "sudo systemctl start firewalld",
      "sudo systemctl restart firewalld",
      "sudo firewall-cmd --permanent --zone=public --add-service=http",
      "sudo firewall-cmd --permanent --zone=public --add-service=https",
      "sudo systemctl restart firewalld",
      "getenforce",
      "sudo restorecon -FR /var/www/mediawiki-1.41.0/",
      "sudo restorecon -FR /var/www/mediawiki",
    ]

    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = file("sai_devops.pem")
      host        = aws_instance.Mediawiki.public_ip
    }
  }
}
output "mediawiki_instance_ip" {
  value = aws_instance.Mediawiki.public_ip
}



