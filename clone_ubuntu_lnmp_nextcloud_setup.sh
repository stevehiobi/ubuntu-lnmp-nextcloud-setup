
echo "##########################################"
echo " Install git"
echo "##########################################"
apt-get install git

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

chmod -R 755 $HOME/ubuntu-lnmp-nextcloud-setup
cd $HOME/ubuntu-lnmp-nextcloud-setup
sudo ./install_nextcloud.sh
