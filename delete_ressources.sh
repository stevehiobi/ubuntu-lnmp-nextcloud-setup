##################################
#Delete MySQL/MariaDb
##################################
sudo systemctl stop mysql
sudo apt-get -y remove --purge mysql-server mysql-client mysql-common
sudo apt-get -y autoremove
sudo apt-get -y autoclean
sudo rm -rf /var/lib/mysql/
sudo rm -rf /etc/mysql/

##################################
#Delete PHP.7.3
##################################
sudo apt-get install -y ppa-purge
sudo ppa-purge ppa:ondrej/php-7.3

##################################
#Remove nginx
##################################
sudo apt-get purge --auto-remove nginx
sudo apt-get autoremove

##################################
#Remove nextcloud
##################################
sudo rm -rf /var/www/nextcloud/