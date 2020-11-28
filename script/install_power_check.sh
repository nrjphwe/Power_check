#! /bin/sh

set -e
cd "$(dirname "$0")/.."


echo "=> Installing apache...\n"
sudo apt update
sudo apt install apache2 -y
sudo a2enmod cgi


echo "=> Installing power_cehck files at CGI-BIN...\n"
sudo cp -v power_check.py /usr/lib/cgi-bin
sudo chmod -R 755 /usr/lib/cgi-bin
sudo chown -R www-data:www-data /usr/lib/cgi-bin

echo "=> Installing PHP...\n"
sudo apt install php libapache2-mod-php -y

echo "=> Installing power check php files at /var/www/html/...\n"
sudo cp -v w3.css /var/www/html
sudo chmod -R 755 /var/www/html/
sudo chown -R www-data:www-data /var/www/html

echo "=> setup for ADS1115 ...\n"
sudo apt-get -y install python3-pip
pip3 install adafruit-circuitpython-ads1x15

echo "=> setup SQL-Mariadb:...\n"
sudo apt install mariadb-server
echo "sudo mysql_secure_installation"
sudo mysql_secure_installation

sudo systemctl stop mariadb
sudo mysqld_safe --skip-grant-tables --skip-networking &
#sudo systemctl start mysql.service
#sudo systemctl start mariadb


echo "python integration to MYSQL"
pip3 install mariadb
sudo apt install python3-mysql.connector
sudo apt-get install phpmyadmin -y
systemctl status mariadb.service

mysql < Power_check/mysql.txt





