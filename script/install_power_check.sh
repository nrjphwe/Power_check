#!/bin/bash
#trap 'read -p "run: $BASH_COMMAND "' DEBUG

#set -e
set -x

cd "$(dirname "$0")/.."

echo  "Authentication=VncAuth" | sudo tee -a  /etc/vnc/config.d/common.custom

echo "=> Installing apache...\n"
sudo apt update
sudo apt install apache2 -y
sudo a2enmod cgi

echo "=> Installing power_check files at CGI-BIN...\n"
sudo cp -v -n power_check.py /usr/lib/cgi-bin
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
sudo apt -y install mariadb-server mariadb-client
echo "sudo mysql_secure_installation"
sudo mysql_secure_installation

echo " === Now some manual steps, copy paste the lines and paste into mysql>           ==="
echo " === after sudo mysql -u root then                                               ==="
echo " === UPDATE mysql.user SET plugin = 'mysql_native_password' WHERE User = 'root'; ==="
echo " === create user pi@localhost identified by "password";                          ==="
echo " === grant all privileges on regattastart.* TO pi@localhost;                     ==="
echo " === FLUSH PRIVILEGES;                                                           ==="
echo " === now mysql -u root                                                           ==="
sudo mysql -u root

echo "now comes: sudo systemctl stop mariadb"
sudo systemctl stop mariadb
#sudo mysqld_safe --skip-grant-tables --skip-networking &
#sudo systemctl start mysql.service
#sudo systemctl start mariadb
## ???

echo "python integration to MYSQL"
pip3 install mariadb
sudo apt install python3-mysql.connector
sudo apt-get install phpmyadmin -y
systemctl status mariadb.service

mysql -h localhost -u pi -p < mysql.txt

sudo apt-get install -y adduser libfontconfig1
wget https://dl.grafana.com/oss/release/grafana_7.3.1_armhf.deb
sudo dpkg -i grafana_7.3.1_armhf.deb

sudo /bin/systemctl daemon-reload
sudo /bin/systemctl enable grafana-server
### You can start grafana-server by executing
sudo /bin/systemctl start grafana-server
systemctl status grafana-server

echo " VNC"
sudo vncpasswd -service
# sudo systemctl start vncserver-x11-serviced.service
# sudo systemctl enable vncserver-x11-serviced.service
sudo systemctl restart vncserver-x11-serviced

echo "sudo nano /usr/lib/cgi-bin/power_check.py"
echo "if needed revise password" 
