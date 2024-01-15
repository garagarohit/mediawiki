#!/bin/bash

# Install the required packages for the db and mediawiki

dnf module reset php -y
dnf module enable php:7.4 -y 
dnf install httpd php php-mysqlnd php-gd php-xml mariadb-server mariadb php-mbstring php-json wget expect tar -y


# Start and enable the services

sudo systemctl start httpd.service
sudo systemctl enable httpd.service
sudo systemctl start mariadb
sudo systemctl enable mariadb

# Secure the MariaDB installation

SECURE_MYSQL=$(expect -c "
set timeout 10
spawn mysql_secure_installation
expect \"Enter current password for root (enter for none):\"
send \"$MYSQL\r\"
expect \"Change the root password?\"
send \"n\r\"
expect \"Remove anonymous users?\"
send \"y\r\"
expect \"Disallow root login remotely?\"
send \"y\r\"
expect \"Remove test database and access to it?\"
send \"y\r\"
expect \"Reload privilege tables now?\"
send \"y\r\"
expect eof
")

echo "$SECURE_MYSQL"

# Create a database and a database user for MediaWiki

mysql -u root --password=$MYSQL -e "CREATE DATABASE my_wiki"
mysql -u root --password=$MYSQL -e "use my_wiki"

mysql -u root --password=$MYSQL -e "CREATE USER 'wikiuser'@'localhost' IDENTIFIED BY 'password';"
mysql -u root --password=$MYSQL -e "GRANT ALL PRIVILEGES ON my_wiki.* TO 'wikiuser'@'localhost' WITH GRANT OPTION;"

# Download and Extract the MediaWiki Files

wget https://releases.wikimedia.org/mediawiki/1.35/mediawiki-1.35.0.tar.gz

sudo mv mediawiki-1.35.0.tar.gz /var/www/html

cd /var/www/html/

sudo tar xvzf /var/www/html/mediawiki-1.35.0.tar.gz

sudo mv /var/www/html/mediawiki-1.35.0 /var/www/html/w
