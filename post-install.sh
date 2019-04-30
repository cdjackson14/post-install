#!/bin/bash

create-alias () {
	# Update the .bashrc with some helpful alias commands
	echo -e "
	alias update='sudo apt update'
	alias install='sudo apt install'
	alias upgrade='sudo apt upgrade'
	alias remove='sudo apt remove'
	alias purge='sudo apt purge'
	alias search='sudo apt search'
	alias pp='ps -ef | grep '
	alias h='history'
	alias sshgat='ssh -C -p2222 g1e0x5r5@jackconsult.com'
	alias sshgen='ssh -C jackchr1@genesis.local'
	alias sshjackjack='ssh -C jackchr1@jackjack.duckdns.org'
	" >> ~/.bashrc &&
	source ~/.bashrc
}

create-swap () {
	sudo fallocate -l 1G /swapfile
	sudo dd if=/dev/zero of=/swapfile bs=1024 count=1048576
	sudo chmod 600 /swapfile
	sudo mkswap /swapfile
	sudo swapon /swapfile
	sudo echo '/swapfile swap swap defaults 0 0' >> /etc/fstab
}

update-upgrade () {
	# Update the system
	sudo apt update &&
	sudo apt upgrade -y
}

build-essentials () {
	# Install the basics for compiling and inside a VM
	sudo apt install -y build-essential module-assistant dkms
}

essentials () {
	# Install the essential stuff for most all Debian based systems (Deb, Ubuntu, RaspberryPi, Kali...)
	sudo apt install -y htop net-tools nmon ssh screen emacs sshfs cmatrix vlc mplayer rtorrent screen exiv2 git
}

optionals () {
	sudo apt install -y rdesktop iftop ircii ubuntu-wallpapers* ubuntu-restricted-extras
}

xfce-goodies () {
	# Install the essential XFCE Ubuntu stuff
	sudo apt install -y xfce4-goodies
}

xfce-gcloud () {
	sudo apt install -y xubuntu-desktop xfce4
}

google-chrome () {
	# Installation of Google Chrome
	if [[ $(getconf LONG_BIT) = "64" ]]
	then
		echo "64bit Detected" &&
		echo "Installing Google Chrome" &&
		wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb &&
		sudo dpkg -i google-chrome-stable_current_amd64.deb &&
		sudo apt --fix-broken install
		rm -f google-chrome-stable_current_amd64.deb
	else
		echo "32bit Detected" &&
		echo "Installing Google Chrome" &&
		wget https://dl.google.com/linux/direct/google-chrome-stable_current_i386.deb &&
		sudo dpkg -i google-chrome-stable_current_i386.deb &&
		sudo apt --fix-broken install
		rm -f google-chrome-stable_current_i386.deb
	fi
}

google-remote () {
	# Install the Google Remote Desktop
	# Visit https://remotedesktop.google.com/headless to register and get code to paste in to terminal later
	# Only ran if the option 'gremote' is added as a switch on the command line
	# https://remotedesktop.google.com/headless
	echo 'Installing the Google Chrome Remote software...'
	wget https://dl.google.com/linux/direct/chrome-remote-desktop_current_amd64.deb
	sudo apt install -y --with-source=chrome-remote-desktop_current_amd64.deb chrome-remote-desktop
	sudo DEBIAN_FRONTEND=noninteractive apt install --assume-yes xfce4 desktop-base
	echo "xfce4-session" > ~/.chrome-remote-desktop-session
	sudo apt install --assume-yes xscreensaver
	sudo systemctl disable lightdm.service
	echo ''
	echo ''
	echo '######################################################################'
	echo 'Hey... since you install the Google Remote, you will want to visit:'
	echo 'https://remotedesktop.google.com/headless'
	echo '######################################################################'
	echo ''
	echo ''
}


ssh-config () {
	# Setup SSH which will require user input, so putting at end of script
	ssh-keygen
}

clean-up () {
	# Clean up everything
	echo "Cleaning Up" &&
	sudo apt -f install &&
	sudo apt autoremove &&
	sudo apt -y autoclean &&
	sudo apt -y clean
}

lamp () {
	# Install the needed items for a basic LAMP
	# Apache
	sudo apt -y install apache2
	# PHP
	sudo apt -y install libapache2-mod-php7.0 php7.0 php7.0-gd php7.0-xml php7.0-curl php7.0-mbstring php7.0-mcrypt php7.0-xmlrpc
	# MySQL (really MariaDB)
	sudo apt install php7.0-mysql mariadb-server mariadb-client
	# Start DB
	sudo systemctl start mariadb
	# Answer the DB wizard
	sudo mysql_secure_installation
	# enable and configure TLS and rewrite modules
	sudo a2enmod rewrite ssl
	sudo a2ensite default-ssl.conf
	
	echo 'Visit https://www.howtoforge.com/tutorial/install-wordpress-5-with-apache-on-debian-9/'
	echo 'You still need to:'
	echo '1. Keep root from logging into DB without password'
	echo '2. Change DocumentRoot directive in'
	echo '    /etc/apache2/sites-enabled/000-default.conf'
	echo '    /etc/apache2/sites-enabled/default-ssl.conf'
	echo ''
	echo '		<Directory /var/www/html>'
	echo '			Options Indexes FollowSymLinks MultiViews'
	echo '			AllowOverride All'
	echo '			Require all granted'
	echo '		</Directory>'
	echo ''
	echo '3. Add default-ssl.conf TLS configuration file'
	echo '4. And then restart a few things listed in the above URL instructions'
	echo ''
}

######################################################################
# Here are the functions that will run.  
# Simple remove what you do not want to execute.
######################################################################
echo 'Nothing has been selected, please edit this file at the bottom'
echo 'and remove the comments for functions you want to execute.'

#create-alias       # set up common helpful alias in .bashrc
#update-upgrade     # issue update and upgrade for everything
#create-swap        # create swap spave on a Micro GCP compute
#build-essentials   # install: build-essential module-assistant dkms
#essentials         # install: htop net-tools nmon ssh screen emacs sshfs cmatrix vlc mplayer rtorrent screen exiv2 git
#optionals          # install: rdesktop iftop ircii ubuntu-wallpapers* ubuntu-restricted-extras
#xfce-goodies       # install: xfce-goodies
#xfce-gcloud        # install: xfce4 for GCP compute
#google-chrome      # install: Google Chrome browser
#google-remote      # install: Google Remote
#ssh-config         # set up SSH keys in .ssh
#clean-up           # clean up everything, no harm for any base here
#lamp               # install: LAMP (Linux, Apache, MariaDB, PHP) on GCP
