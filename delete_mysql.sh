sudo systemctl stop mysql
sudo apt-get -y remove --purge mysql-server mysql-client mysql-common
sudo apt-get -y autoremove
sudo apt-get -y autoclean
sudo rm -rf /var/lib/mysql/
sudo rm -rf /etc/mysql/