#!/bin/bash
# Easy install of Cheat
# Author : astalios @ 2021-11-04
# Version : 1.0

if [ "$EUID" -ne 0 ]
then echo "You are not root, exiting !"
exit 1
fi

function install(){
#Install dependencies and usefull packages
apt install vim sudo rsync git mlocate openssl -y
wget https://github.com/cheat/cheat/releases/download/4.2.3/cheat-linux-amd64.gz
#Unzip the directory, Give execution rights, Move the directory and create the common directory
gunzip -v cheat-linux-amd64.gz
chmod +x cheat-linux-amd64
mv -v cheat-linux-amd64 /usr/local/bin/cheat
mkdir -vp /opt/COMMUN
}

function dirCheats(){
#Creating the Cheat directory and init the config file, Getting all community cheats from Github, Creating community and personnal cheats' directories
mkdir -vp /opt/COMMUN/cheat && cheat --init > /opt/COMMUN/cheat/conf.yml
git clone https://github.com/cheat/cheatsheets
mkdir -vp /opt/COMMUN/cheat/cheatsheets/{community,personal}
#Move all community cheats to our community directory
mv ~/cheatsheets/* /opt/COMMUN/cheat/cheatsheets/community
#Remove downloaded cheatsheets, Create the common group, modify group owner and allow all users of the common group to modify the sheets
rm -rf ~/cheatsheets
}

function groups(){
#Create groups, change rights of cheat to the common group
addgroup commun
chgrp -vR commun /opt/COMMUN/cheat
chmod -vR 550 /opt/COMMUN/cheat/
}

function confFiles(){
#Mofify the config file to tell the new way to look for cheatsheets, Create a link between user directory and common one
sed -i 's; /root/.config/; /opt/COMMUN/;' /opt/COMMUN/cheat/conf.yml
mkdir -pv /root/.config
ln -s /opt/COMMUN/cheat /root/.config/cheat
mkdir /etc/skel/.config
ln -s /opt/COMMUN/cheat /etc/skel/.config/cheat
}

function usersCreation(){
#Create the user esgi and give it the groups
sudo useradd --create-home --shell /bin/bash --password $(echo "esgi" | openssl passwd -crypt -stdin) esgi
sudo usermod -aG esgi esgi
sudo usermod -aG sudo esgi
sudo usermod -aG commun esgi
#Get the user created when the machine was created and add it to the groups
usr=$(id -un 1000)
sudo usermod -aG sudo $usr
sudo usermod -aG commun $usr
mkdir -pv /home/$usr/.config
ln -s /opt/COMMUN/cheat /home/$usr/.config/cheat
<<<<<<< HEAD
chown -R $usr:$usr /home/$usr/.config/
=======
chown -R $usr:$usr /home/$usr/.config
>>>>>>> db03802a53a9f3bb74f1e86fcd5a75522aad8597
echo "All done ! You should try cheat -l to see all your Cheatsheets !"
}

function deleteJunk(){
apt remove vim sudo rsync git mlocate openssl -y
rm -vrf /usr/local/bin/cheat
rm -vrf /opt/COMMUN/
delgroup commun
rm -vrf /root/.config/cheat
pkill -KILL -u esgi
deluser --remove-home esgi
usr=$(id -un 1000)
rm -vr /home/$usr/.config/cheat
}

INSTALL="install"
UNINSTALL="uninstall"
HELP="help"
if [ -z "$1" ]
then
  echo "No arguments supplied \n"
  echo "list of arguments : \n - install \n - uninstall \n - help"
elif [ $INSTALL == $1 ]
then
  install
  dirCheats
  groups
  confFiles
  usersCreation
  exit 0
elif [ $UNINSTALL == $1 ]
then
  deleteJunk
  exit 0
elif [ $HELP == $1 ]
then
  echo "list of arguments : \n - install \n - uninstall \n - help"
  exit 1
fi
