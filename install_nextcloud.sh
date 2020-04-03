#!/bin/bash

##################################
# Check if user is root
##################################

if [ "$(id -u)" != "0" ]; then
    echo "Error: You must be root to run this script, please use the root user to install the software."
    echo ""
    echo "Use 'sudo su - root' to login as root"
    exit 1
fi

##################################
# Welcome
##################################

echo ""
echo "Welcome to ubuntu-nextcloud-nginx-web-server setup script."
echo ""

#Update and upgrade repositories packages
echo "##########################################"
echo " Updating Packages"
echo "##########################################"
apt-get update
apt-get upgrade -y
apt-get autoremove -y --purge
apt-get autoclean -y

echo "##########################################"
echo " Installing useful packages"
echo "##########################################"
apt-get install -y wget curl git unzip zip

##################################
# Clone repository
##################################
echo "###########################################"
echo " Clone ubuntu-lnmp-nextcloud-setup"
echo "###########################################"

if [ ! -d $HOME/ubuntu-lnmp-nextcloud-setup ]; then
        git clone https://github.com/stevehiobi/ubuntu-lnmp-nextcloud-setup.git $HOME/ubuntu-lnmp-nextcloud-setup
else
        git -C $HOME/ubuntu-lnmp-nextcloud-setup pull
fi

#Now install NGINX
if [ ! -d /etc/nginx ]; then
        #Install MariaDB
        echo ""
        echo "##########################################"
        echo " Installing Nginx"
        echo "##########################################"
        #Add key for nginx-Repositories
        curl -fsSL https://nginx.org/keys/nginx_signing.key | sudo apt-key add -
        apt-get install nginx -y
        systemctl enable nginx
        systemctl start nginx
fi
sleep 1
if [ ! -d /etc/mysql ]; then
        #Install MariaDB
        echo ""
        echo "##########################################"
        echo " Installing MariaDB server"
        echo "##########################################"
        #Add key for repository
        apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0xF1656F24C74CD1D8
        # generate random password
        MYSQL_ROOT_PASS=$(date +%s | sha256sum | base64 | head -c 32)
        # install mariadb server
        apt-get install -y mariadb-server
        # save credentials in .my.cnf and copy it in /etc/mysql/conf.d for easyengine
        echo -e '[client]\nuser = root' > $HOME/.my.cnf
        echo "password = $MYSQL_ROOT_PASS" >>$HOME/.my.cnf
        cp -f $HOME/.my.cnf /etc/mysql/conf.d/my.cnf
        #1. Set password for root user
        #2. Delete anonymus user
        #3. Ensure the root user can not log in remotely
        #4. Remove the database named “test”;
        #5.Flush the privileges tables, to ensure that changes are applied
        ## mysql_secure_installation non-interactive way
        mysql -e "UPDATE mysql.user SET Password=PASSWORD('$MYSQL_ROOT_PASS') WHERE User='root'"
        # remove anonymous users
        mysql -e "DELETE FROM mysql.user WHERE User='';"
        mysql -e "DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1')"
        # remove test database
        mysql -e "DROP DATABASE IF EXISTS test"
        mysql -e "DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%'"
        mysql -e "UPDATE mysql.user set plugin='mysql_native_password' where User='root'"
        # flush privileges
        mysql -e "FLUSH PRIVILEGES"
        # reload daemon
        systemctl daemon-reload
        # restart mysql
        systemctl restart mariadb
fi
sleep 1
if [ ! -f /etc/php/7.3/fpm/php.ini ]; then
        echo "##########################################"
        echo " Installing php7.3-fpm"
        echo "##########################################"
        sudo apt-get install software-properties-common
        sudo add-apt-repository ppa:ondrej/php -y
        sudo apt-get update
        sudo apt-get upgrade -y
        apt-get install -y php-imagick php7.3-common php7.3-pdo php7.3-mysql php7.3-fpm php7.3-gd php7.3-json php7.3-curl php7.3-zip php7.3-xml php7.3-bcmath php7.3-mbstring php7.3-bz2 php7.3-intl
        systemctl enable php7.3-fpm 
        systemctl start php7.3-fpm
fi
sleep 1

##################################
#Create Nextcloud database
##################################
if ! mysql -e 'use nextcloud'; then
        echo "##########################################"
        echo "Create Nextcloud database"
        echo "##########################################"
        mysql -e "CREATE DATABASE nextcloud DEFAULT CHARACTER SET utf8 COLLATE utf8_unicode_ci"
        mysql -e "GRANT ALL ON nextcloud.* TO 'nextclouduser'@'localhost' IDENTIFIED BY 'nextcloud'"
        mysql -e "FLUSH PRIVILEGES"
        systemctl restart mariadb
fi
sleep 1

##################################
#Download Nextcloud"
##################################
if [ ! -d /var/www/nextcloud ]; then
        echo "##########################################"
        echo "Download Nextcloud"
        echo "##########################################"
        mkdir $HOME/temp && cd $HOME/temp
        wget  https://download.nextcloud.com/server/releases/latest.zip
        unzip latest.zip
        sudo mv nextcloud /var/www/nextcloud/
        sudo chown -R www-data:www-data /var/www/nextcloud/
        sudo chmod -R 755 /var/www/nextcloud/
fi
sleep 1

##################################
#Create nextcloud.conf file in /etc/nginx/conf.d/ directory"
##################################
if [ ! -f /etc/nginx/conf.d/nextcloud.conf ]; then
        echo "##########################################"
        echo "Create nextcloud.conf file in /etc/nginx/conf.d/ directory"
        echo "##########################################"
        cp $HOME/ubuntu-lnmp-nextcloud-setup/nextcloud_HTTP_nginx.conf /etc/nginx/conf.d/nextcloud.conf
        VERIFY_NGINX_CONFIG=$(nginx -t 2>&1 | grep failed)
        if [ -z "$VERIFY_NGINX_CONFIG" ]; then
                echo "##########################################"
                echo "Reloading Nginx"
                echo "##########################################"
                systemctl restart nginx
        else
                echo "##########################################"
                echo "Nginx configuration is not correct"
                echo "##########################################"
                exit -1
        fi
fi