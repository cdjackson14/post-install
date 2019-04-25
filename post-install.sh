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
	" >> .bashrc &&
	source ~/.bashrc
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
	sudo apt install -y net-tools nmon ssh screen emacs sshfs cmatrix vlc mplayer rtorrent screen exiv2 
}

optionals () {
	sudo apt install -y rdesktop iftop ircii ubuntu-wallpapers* ubuntu-restricted-extras
}

xfce () {
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

######################################################################
# Here are the functions that will run.  
# Simple remove what you do not want to execute.
######################################################################
echo 'Nothing has been selected, please edit this file at the bottom'
echo 'and remove the comments for functions you want to execute.'

# create-alias
# update-upgrade
# build-essentials
# essentials
# optionals
# xfce
# xfce-gcloud
# google-chrome
# google-remote 
# ssh-config
# clean-up
