#!/bin/bash

echo ''
echo ''
echo '################################################################################'
echo '     Updating the .bashrc'
echo '################################################################################'

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

echo ''
echo ''
echo '################################################################################'
echo '     Updating the core system'
echo '################################################################################'
# Update the system
sudo apt update &&
sudo apt upgrade -y

echo ''
echo ''
echo '################################################################################'
echo '     Install a bunch of basic goodies that I think we will want'
echo '################################################################################'
# Install the basics for compiling and inside a VM
sudo apt install -y build-essential module-assistant dkms

# Install the essential Ubuntu stuff and typical stuff
sudo apt install -y net-tools nmon ssh screen ssh emacs sshfs iftop ircii rdesktop exiv2 mplayer rtorrent screen cmatrix vlc ubuntu-wallpapers* 

echo ''
echo ''
echo '################################################################################'
echo '     Installing Google Chrome web browser'
echo '################################################################################'
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

echo ''
echo ''
echo '################################################################################'
echo '     Installing XFCE/Ubuntu needed stuff'
echo '################################################################################'
# Install the essential XFCE Ubuntu stuff
sudo apt install -y xubuntu-desktop xfce4 xfce4-goodies


echo ''
echo ''
echo '################################################################################'
echo '     Installing Google Remote Desktop'
echo '################################################################################'
# Install the Google Remote Desktop
# Visit https://remotedesktop.google.com/headless to register and get code to paste in to terminal later
# Only ran if the option 'gremote' is added as a switch on the command line
# https://remotedesktop.google.com/headless
if [[ $1 = "gremote" ]]
then
	echo 'Installing the Google Chrome Remote software...'
	wget https://dl.google.com/linux/direct/chrome-remote-desktop_current_amd64.deb
	sudo apt install -y --with-source=chrome-remote-desktop_current_amd64.deb chrome-remote-desktop
	sudo DEBIAN_FRONTEND=noninteractive apt install --assume-yes xfce4 desktop-base
	echo "xfce4-session" > ~/.chrome-remote-desktop-session
	sudo apt install --assume-yes xscreensaver
	sudo systemctl disable lightdm.service
else
	echo 'The "gremote" option was not specified, skipping install and config of Google Chrome Remote.'
fi

echo ''
echo ''
echo '################################################################################'
echo '     Installing the restricted Ubuntu stff'
echo '################################################################################'
# Install extra, which will require user input, so putting at end of script
sudo apt-get install -y ubuntu-restricted-extras

echo ''
echo ''
echo '################################################################################'
echo '     Setting up the SSH keys'
echo '################################################################################'
# Setup SSH which will require user input, so putting at end of script
ssh-keygen

echo ''
echo ''
echo '################################################################################'
echo '     OK, we are finally done, not let us clean up...'
echo '################################################################################'
# Clean up everything
echo "Cleaning Up" &&
sudo apt -f install &&
sudo apt autoremove &&
sudo apt -y autoclean &&
sudo apt -y clean

if [[ $1 = "gremote" ]]
then
	echo ''
	echo ''
	echo ''
	echo 'Hey... since you install the Google Remote, you will want to visit:'
	echo ''
	echo 'https://remotedesktop.google.com/headless'
fi
