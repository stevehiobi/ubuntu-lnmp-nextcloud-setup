##################################
#Delete MySQL/MariaDb
##################################
echo '##################################'
echo 'Delete MySQL/MariaDb'
echo '##################################'
sudo systemctl stop mysql
sudo apt-get -y remove --purge mysql-server mysql-client mysql-common
sudo rm -rf /var/lib/mysql/
sudo rm -rf /etc/mysql/

##################################
#Delete PHP.7.3
##################################
echo '##################################'
echo 'Delete PHP.7.3'
echo '##################################'
sudo apt-get install -y ppa-purge
sudo ppa-purge ppa:ondrej/php-7.3

##################################
#Remove nginx
##################################
echo '##################################'
echo 'Remove nginx'
echo '##################################'
sudo apt-get purge --auto-remove nginx -y

##################################
#Remove nextcloud
##################################
echo '##################################'
echo 'Remove nextcloud'
echo '##################################'
sudo rm -rf /var/www/nextcloud/

##################################
#Cleanup unused packegas
##################################
echo '##################################'
echo 'Cleanup unused packegas'
echo '##################################'
sudo apt-get -y autoremove --purge
sudo apt-get -y autoclean