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

# copy original power_check file to /usr/lib/cgi-bin
# sudo cp -v power_check.py /usr/lib/cgi-bin
# We start the power_check script on boot by using systemd file
sudo cp -v script/power_check.service /lib/systemd/system
sudo chmod 644 /lib/systemd/system/power_check.service
sudo systemctl daemon-reload
sudo systemctl enable power_check.service
#export PYTHONPATH="${PYTHONPATH}:/usr/lib/cgi-bin"
#export PYTHONPATH="${PYTHONPATH}:/home/pi/.local/lib/python3.7"
#

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

echo " === Now some manual steps, copy the lines and paste into mysql                  ==="
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

echo "python integration to MYSQL"
pip3 install mariadb
sudo apt install python3-mysql.connector
sudo apt-get install phpmyadmin -y
sudo systemctl start mysql.service
sleep 5
systemctl status mariadb.service

# import/add sql data to db
mysql -h localhost -u pi -p < mysql.txt

# install Grafana
sudo apt-get install -y adduser libfontconfig1
wget https://dl.grafana.com/oss/release/grafana_7.3.1_armhf.deb
sudo dpkg -i grafana_7.3.1_armhf.deb
sudo /bin/systemctl daemon-reload
sudo /bin/systemctl enable grafana-server
### You can start grafana-server by executing
sudo /bin/systemctl start grafana-server
systemctl status grafana-server

# start upp VNC
echo " VNC"
sudo vncpasswd -service
# sudo systemctl start vncserver-x11-serviced.service
# sudo systemctl enable vncserver-x11-serviced.service
sudo systemctl restart vncserver-x11-serviced

# original file contains dummy passwd.
echo "sudo nano /usr/lib/cgi-bin/power_check.py"
echo "if needed revise password" 

# create an entry in crontab by crontab -e, then in the bottom add
# @reboot sudo -H -u pi /usr/bin/python3 /usr/lib/cgi-bin/power_check.py &
