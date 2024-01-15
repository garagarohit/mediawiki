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
      "yum install centos-release-scl",
      "sudo yum install -y httpd24-httpd rh-php73 rh-php73-php rh-php73-php-mbstring rh-php73-php-mysqlnd rh-php73-php-gd rh-php73-php-xml mariadb-server mariadb wget",
      "sudo systemctl start mariadb",
      "sudo systemctl enable mariadb",
      "mysql_secure_installation",
      "mysql -u root -p",
      "sudo mysql -e 'CREATE DATABASE mediawiki_db;'",
      "sudo mysql -e 'CREATE USER mediawiki_user@localhost IDENTIFIED BY \"your-password\";'",
      "sudo mysql -e 'GRANT ALL PRIVILEGES ON mediawiki_db.* TO mediawiki_user@localhost;'",
      "sudo mysql -e 'FLUSH PRIVILEGES;'",
      "wget https://releases.wikimedia.org/mediawiki/1.41/mediawiki-1.41.0.tar.gz.sig",
      "cd /var/www",
      "tar -zxvf mediawiki-1.41.0.tar.gz",
      "ln -s mediawiki-1.41.0/ mediawiki",
      "sudo chown -R apache:apache /var/www/html/mediawiki/",
      "firewall-cmd --permanent --zone=public --add-service=http",
      "firewall-cmd --permanent --zone=public --add-service=https",
      "systemctl restart firewalld",
      "getenforce",
      "restorecon -FR /var/www/mediawiki-1.41.0/",
      "restorecon -FR /var/www/mediawiki"
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



