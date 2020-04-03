#!/bin/bash
systemctl stop nginx
#=====chg-data-dir
STR1="/var/www/nextcloud/data"
STR2="/var/www/nextcloud/data/.ocdata"
STR4="/media/data"
#echo $STR1
#echo $STR2
#echo $STR4
cp $STR1 /media -R
echo "copy data done"
cp $STR2 STR4
echo "copy .oc done"
chown www-data:www-data $STR4 -R
echo "Permission done"
echo "before sed"
sed -i "s|$STR1|$STR4|g" /var/www/nextcloud/config/config.php
echo "after sed"
#======php-settings
sed -i 's/memory_limit = 128M/memory_limit = 512M/g' /etc/php/7.3/fpm/php.ini
#==================
sed -i 's/;clear_env = no/clear_env = no/g' /etc/php/7.3/fpm/pool.d/www.con