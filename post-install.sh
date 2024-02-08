#!/bin/bash

# Created by Chris Jackson, cdjackson14@gmail.com
# Can be used on many Debian based installs, like Ubuntu, Raspberry Pi, Kali, and GCP Linux computes
#
# Top is all functions, the bottom lines contain the menu and action.
VERSION=3.6
# Found that Chromebooks don't have lsb-release install by default, so
# switching to looking in /etc/os-release
#	BUILD=`lsb_release -i | awk {'print $3'} | tr '[:upper:]' '[:lower:]'`
#	RELEASE=`lsb_release -r | awk {'print $2'}`
#	CODENAME=`lsb_release -c | awk {'print $2'} | tr '[:upper:]' '[:lower:]'`
BUILD=`grep ^ID= /etc/os-release | awk -F = '{ print $2 }' | tr '[:lower:]' '[:upper:]'`
RELEASE=`grep ^VERSION_ID= /etc/os-release | awk -F = '{ print $2 }' | sed s/\"//g`
CODENAME=`grep VERSION_CODENAME /etc/os-release | awk -F = '{ print $2 }'`
declare -a POSTMSG


##############################
# FUNCTIONS
##############################

set-bashrc () {
	# Update the .bashrc with some helpful alias commands
	echo -e "
alias update='sudo apt update; apt list --upgradable'
alias install='sudo apt install'
alias upgrade='sudo apt upgrade'
alias remove='sudo apt remove'
alias purge='sudo apt purge'
alias search='sudo apt search'
alias pp='ps -ef | grep '
alias h='history'
" >> ~/.bashrc &&
	source ~/.bashrc

	# Any message to display post all selected installs and configs.  Listed in a end summary.
	POSTMSG[${COUNT}]="${FUNCNAME} "
}

create-swap () {
	sudo fallocate -l 1G /swapfile
	sudo dd if=/dev/zero of=/swapfile bs=1024 count=1048576
	sudo chmod 600 /swapfile
	sudo mkswap /swapfile
	sudo swapon /swapfile
	echo '/swapfile swap swap defaults 0 0' | sudo tee -a /etc/fstab

	# Any message to display post all selected installs and configs.  Listed in a end summary.
	POSTMSG[${COUNT}]="${FUNCNAME} "
}


update-upgrade () {
	# Update the system
	sudo apt update &&
	sudo apt upgrade -y

	# Any message to display post all selected installs and configs.  Listed in a end summary.
	POSTMSG[${COUNT}]="${FUNCNAME} "
}

build-essentials () {
	# Install the basics for compiling and inside a VM
	sudo apt install -y build-essential module-assistant dkms

	# Any message to display post all selected installs and configs.  Listed in a end summary.
	POSTMSG[${COUNT}]="${FUNCNAME} "
}

essentials () {
	# Install the essential stuff for most all Debian based systems (Deb, Ubuntu, RaspberryPi, Kali...)
	sudo apt install -y htop vim net-tools nmon ssh tmux sshfs cmatrix vlc mplayer rtorrent exiv2 git cifs-utils exfatprogs gparted
	sudo apt install -y exfat-utils 

	# Any message to display post all selected installs and configs.  Listed in a end summary.
	POSTMSG[${COUNT}]="${FUNCNAME} "
}

optionals () {
	# Added the ~n needed when install wildcards using apt (or I could have fallen back to apt-get)
	sudo apt install -y rdesktop iftop ircii ubuntu-restricted-extras

	# Any message to display post all selected installs and configs.  Listed in a end summary.
	POSTMSG[${COUNT}]="${FUNCNAME} "
}

qemu-guest () {
	#sudo apt install -y qemu-guest-agent spice-vdagent
	mkdir -p ~/bin
	echo $'#!/usr/bin/bash
xrandr --output  \"$(xrandr | awk \'/ connected/{print $1; exit; }\')\" --auto' > ~/bin/display-resizer
	chmod 777 ~/bin/display-resizer

	echo -e "[Desktop Entry]
Version=1.0
Type=Application
Name=Resize Display
Comment=Resize display to match the current VM display
Exec=${HOME}/bin/display-resizer
Icon=ccsm
Path=
Terminal=false
StartupNotify=false
" > ~/Desktop/Display-Resizer.desktop


	# Any message to display post all selected installs and configs.  Listed in a end summary.
	POSTMSG[${COUNT}]="${FUNCNAME}: display-resizer (to change screen to window size) was place in ~/bin/ "
}

wallpapers () {
	# Things to install with wildcard (for Ubuntu 20.04+)
	sudo apt install -y '~nubuntu-wallpapers*'
	if [[ $? = 100 ]]
	then
		# Maybe this is not Ubuntu 20+, so fall back to the old behavious of apt
		sudo apt install -y ubuntu-wallpapers*
	fi

	# Any message to display post all selected installs and configs.  Listed in a end summary.
	POSTMSG[${COUNT}]="${FUNCNAME} "
}

gui-software () {
	sudo apt install -y pinta keepassxc color-picker
	
	# Install AppImageLauncher
	sudo apt install -y software-properties-common
	sudo add-apt-repository -y ppa:appimagelauncher-team/stable
	sudo apt update
	sudo apt install -y appimagelauncher

	# Any message to display post all selected installs and configs.  Listed in a end summary.
	POSTMSG[${COUNT}]="${FUNCNAME} "
}

xfce-goodies () {
	# Install the essential XFCE Ubuntu stuff
	sudo apt install -y xfce4-goodies plank

	# Setup the terminal like we like it
	termConfigPath=${HOME}/.config/xfce4/terminal
	mkdir -p ${termConfigPath}
	echo "[Configuration]
FontName=DejaVu Sans Mono 12
MiscAlwaysShowTabs=FALSE
MiscBell=FALSE
MiscBellUrgent=FALSE
MiscBordersDefault=TRUE
MiscCursorBlinks=FALSE
MiscCursorShape=TERMINAL_CURSOR_SHAPE_BLOCK
MiscDefaultGeometry=120x34
MiscInheritGeometry=FALSE
MiscMenubarDefault=TRUE
MiscMouseAutohide=FALSE
MiscMouseWheelZoom=TRUE
MiscToolbarDefault=FALSE
MiscConfirmClose=TRUE
MiscCycleTabs=TRUE
MiscTabCloseButtons=TRUE
MiscTabCloseMiddleClick=TRUE
MiscTabPosition=GTK_POS_TOP
MiscHighlightUrls=TRUE
MiscMiddleClickOpensUri=FALSE
MiscCopyOnSelect=FALSE
MiscShowRelaunchDialog=TRUE
MiscRewrapOnResize=TRUE
MiscUseShiftArrowsToScroll=FALSE
MiscSlimTabs=FALSE
MiscNewTabAdjacent=FALSE
MiscSearchDialogOpacity=100
MiscShowUnsafePasteDialog=TRUE
ColorPalette=#000000;#aa0000;#44aa44;#aa5500;#0039aa;#aa22aa;#1a92aa;#aaaaaa;#777777;#ff8787;#4ce64c;#ded82c;#295fcc;#cc58cc;#4ccce6;#ffffff
ColorForeground=#b7b7b7
ColorBackground=#131926
ColorCursor=#0f4999
ColorSelection=#163b59
ColorSelectionUseDefault=FALSE
ColorBold=#ffffff
ColorBoldUseDefault=FALSE
TabActivityColor=#0f4999" > ${termConfigPath}/terminalrc

	# Also update Mouspad look and feel
	gsettings set org.xfce.mousepad.preferences.view auto-indent true
	gsettings set org.xfce.mousepad.preferences.view color-scheme 'cobalt'
	gsettings set org.xfce.mousepad.preferences.view font-name 'DejaVu Sans Mono 12'
	gsettings set org.xfce.mousepad.preferences.view highlight-current-line true
	gsettings set org.xfce.mousepad.preferences.view indent-on-tab true
	gsettings set org.xfce.mousepad.preferences.view indent-width -1
	gsettings set org.xfce.mousepad.preferences.view show-line-endings true
	gsettings set org.xfce.mousepad.preferences.view show-line-numbers true
	gsettings set org.xfce.mousepad.preferences.view show-whitespace true
	gsettings set org.xfce.mousepad.preferences.view word-wrap true
	gsettings set org.xfce.mousepad.preferences.view.show-whitespace inside true
	gsettings set org.xfce.mousepad.preferences.view.show-whitespace leading true
	gsettings set org.xfce.mousepad.preferences.view.show-whitespace trailing true
	gsettings set org.xfce.mousepad.preferences.window always-show-tabs true

	# Config Plank to autorun at login
	autoStart=${HOME}/.config/autostart
	mkdir -p ${termConfigPath}
	echo "[Desktop Entry]
Encoding=UTF-8
Version=0.9.4
Type=Application
Name=Plank
Comment=Plank menu start bar
Exec=plank
OnlyShowIn=XFCE;
RunHook=0
StartupNotify=false
Terminal=false
Hidden=false" > ${autoStart}/Plank.desktop


	# Any message to display post all selected installs and configs.  Listed in a end summary.
	POSTMSG[${COUNT}]="${FUNCNAME} "
}

xfce-gcloud () {
	sudo apt install -y xubuntu-desktop xfce4

	# Any message to display post all selected installs and configs.  Listed in a end summary.
	POSTMSG[${COUNT}]="${FUNCNAME} "
}

brave-browser () {
	# Install of Brave Browser.  Instructions right on https://brave.com/linux/
	sudo apt install -f curl
	sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
	echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg] https://brave-browser-apt-release.s3.brave.com/ stable main"|sudo tee /etc/apt/sources.list.d/brave-browser-release.list
	sudo apt update
	sudo apt install -y brave-browser

	# Any message to display post all selected installs and configs.  Listed in a end summary.
	POSTMSG[${COUNT}]="${FUNCNAME} "
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

	# Any message to display post all selected installs and configs.  Listed in a end summary.
	POSTMSG[${COUNT}]="${FUNCNAME} "
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
	sudo systemctl disable lightdm.service

	# Any message to display post all selected installs and configs.  Listed in a end summary.
	POSTMSG[${COUNT}]="${FUNCNAME}: Visit https://remotedesktop.google.com/headless for setting up the connection."
}

calibre () {
	# Install Calibre most recent version
	# Install pre-requisit for Ubuntu
	install libxcb-cursor0
	# Install using the main script as shown on the Calibre download page for Linux
	sudo -v && wget -nv -O- https://download.calibre-ebook.com/linux-installer.sh | sudo sh /dev/stdin

	# Any message to display post all selected installs and configs.  Listed in a end summary.
	POSTMSG[${COUNT}]="${FUNCNAME}: Ready to run and import your ebooks. "
}

ssh-config () {
	# Setup SSH which will require user input, so putting at end of script
	ssh-keygen

	# Any message to display post all selected installs and configs.  Listed in a end summary.
	POSTMSG[${COUNT}]="${FUNCNAME} "
}

clean-up () {
	# Clean up everything
	echo "Cleaning Up" &&
	sudo apt -f install &&
	sudo apt -y autoremove &&
	sudo apt -y autoclean &&
	sudo apt -y clean

	# Any message to display post all selected installs and configs.  Listed in a end summary.
	POSTMSG[${COUNT}]="${FUNCNAME} "
}

lamp () {
	# Install the needed items for a basic LAMP
	# Apache
	sudo apt -y install apache2
	# PHP
	sudo apt -y install libapache2-mod-php7.3 php7.3 php7.0-gd php7.0-xml php7.0-curl php7.0-mbstring php7.0-mcrypt php7.0-xmlrpc
	# MySQL (really MariaDB)
	sudo apt install php7.0-mysql mariadb-server mariadb-client
	# Start DB
	sudo systemctl start mariadb
	# Answer the DB wizard
	sudo mysql_secure_installation
	# enable and configure TLS and rewrite modules
	sudo a2enmod rewrite ssl
	sudo a2ensite default-ssl.conf
	
	# Allow Emacs to color code PHP and web pages
	sudo apt -y install php-elisp
	
	# Install phpMyAdmin
	# https://www.digitalocean.com/community/tutorials/how-to-install-and-secure-phpmyadmin-on-debian-9
	sudo apt -y install phpmyadmin php-mbstring php-gettext
	echo 'Post phpMyAdmin config and security at:'
	echo 'https://www.digitalocean.com/community/tutorials/how-to-install-and-secure-phpmyadmin-on-debian-9'
	echo ''
	
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

	# Any message to display post all selected installs and configs.  Listed in a end summary.
	POSTMSG[${COUNT}]="${FUNCNAME} "
}

lap-no-m () {
	# Install the needed items for a basic LAMP (no MySQL)
	# Apache
	sudo apt -y install apache2
	# PHP
	sudo apt -y install php7.3 php7.3-cli php7.3-common
	# MySQL PHP connector only
	sudo apt install php7.3-mysql
	# enable and configure TLS and rewrite modules
	sudo a2enmod rewrite ssl
	sudo a2ensite default-ssl.conf
	
	# Allow Emacs to color code PHP and web pages
	sudo apt -y install php-elisp

	# Any message to display post all selected installs and configs.  Listed in a end summary.
	POSTMSG[${COUNT}]="${FUNCNAME} "
}

realtek-wifi () {
	sudo apt install build-essential git libelf-dev dkms bc
	#sudo apt install raspberrypi-kernel-headers raspberrypi-kernel
	git clone https://github.com/cilynx/rtl88x2BU_WiFi_linux_v5.3.1_27678.20180430_COEX20180427-5959.git
	cd rtl88x2BU_WiFi_linux_v5.3.1_27678.20180430_COEX20180427-5959
	VER=$(sed -n 's/\PACKAGE_VERSION="\(.*\)"/\1/p' dkms.conf)
	sudo rsync -rvhP ./ /usr/src/rtl88x2bu-${VER}
	sudo dkms add -m rtl88x2bu -v ${VER}
	sudo dkms build -m rtl88x2bu -v ${VER}
	sudo dkms install -m rtl88x2bu -v ${VER}
	sudo modprobe 88x2bu

	# Any message to display post all selected installs and configs.  Listed in a end summary.
	POSTMSG[${COUNT}]="${FUNCNAME} "
}

tor () {
	# Find the current version
	TOR_VERSION=`wget -q -O - https://www.torproject.org/download/languages/ | grep 'linux' | awk -F '/' '{ print $5 }'`

	# Install the TOR Browser on Linux
	# TOR_FILE=tor-browser-linux64-${TOR_VERSION}_en-US.tar.xz
	TOR_FILE=tor-browser-linux64-${TOR_VERSION}_ALL.tar.xz
	TOR_LINK=https://dist.torproject.org/torbrowser/${TOR_VERSION}/${TOR_FILE}

	# Download, untar, and set up for use
	wget ${TOR_LINK}
	tar -xf ${TOR_FILE}
	rm ${TOR_FILE}
	echo '#!/bin/bash' > ./tor-browser/copy-to-start-menu.sh 
	echo 'mkdir -p ~/.local/share/applications/' >> ./tor-browser/copy-to-start-menu.sh
	echo 'cp start-tor-browser.desktop ~/.local/share/applications/' >> ./tor-browser/copy-to-start-menu.sh
	chmod 777 ./tor-browser/copy-to-start-menu.sh

	# Any message to display post all selected installs and configs.  Listed in a end summary.
	POSTMSG[${COUNT}]="${FUNCNAME} "
}

expressvpn () {
	# BASE_URL=https://www.expressvpn.works/clients/linux
	BASE_URL=https://download.expressvpn.xyz/clients/linux
	
	FILE_1=expressvpn_3.37.0.2-1_amd64.deb
	wget ${BASE_URL}/${FILE_1}
	sudo dpkg -i ${FILE_1}
	rm ${FILE_1}

	# Any message to display post all selected installs and configs.  Listed in a end summary.
	POSTMSG[${COUNT}]="${FUNCNAME}: expressvpn activate ERGQ8M5C6PWCOVTJDW9T05Q"
}

kernel-latest () {
	BASE_URL=https://kernel.ubuntu.com/~kernel-ppa/mainline/v5.4.6/
	FILE_1=linux-headers-5.4.6-050406_5.4.6-050406.201912211140_all.deb
	FILE_2=linux-headers-5.4.6-050406-generic_5.4.6-050406.201912211140_amd64.deb
	FILE_3=linux-image-unsigned-5.4.6-050406-generic_5.4.6-050406.201912211140_amd64.deb
	FILE_4=linux-modules-5.4.6-050406-generic_5.4.6-050406.201912211140_amd64.deb
	sudo apt update &&
	sudo apt upgrade -y 
	wget ${BASE_URL}/${FILE_1}
	wget ${BASE_URL}/${FILE_2}
	wget ${BASE_URL}/${FILE_3}
	wget ${BASE_URL}/${FILE_4}
	sudo dpkg -i ${FILE_1} ${FILE_2} ${FILE_3} ${FILE_4}
	rm ${FILE_1} ${FILE_2} ${FILE_3} ${FILE_4}
	sudo reboot

	# Any message to display post all selected installs and configs.  Listed in a end summary.
	POSTMSG[${COUNT}]="${FUNCNAME} "
}

realvnc () {
	VNCSERVER=VNC-Server-6.11.0-Linux-x64.deb
	VNCVIEWER=VNC-Viewer-6.22.315-Linux-x64.deb
	VNCURL=http://home.jackson.pub/dl/

	# Download the RealVNC files
	wget ${VNCURL}${VNCSERVER}
	wget ${VNCURL}${VNCVIEWER}
	
	# Install both
	sudo dpkg --install $VNCSERVER
	sudo apt install -f -y
	sudo dpkg --install $VNCVIEWER
	sudo apt install -f -y

	# Set up a nice alias for starting up with multiple resolutions
	# echo "alias vv='vncserver :28 -geometry 1280x800 -randr 1280x800,1024x768,1920x1080,1280x1024,1600x1200,1440x900,1600x900,2880x1800,1680x1050'" >> ~/.bashrc
	
	# Remove the install files
	rm $VNCSERVER
	rm $VNCVIEWER

	# Any message to display post all selected installs and configs.  Listed in a end summary.
	POSTMSG[${COUNT}]="${FUNCNAME}: sudo vnclicense -add 4326B-7H7LA-RG5F2-292D5-9LTTA"
}

realvnc-xfce-add () {
	# This is needed to get RealVNC Server working on XFCE (specifically Xubuntu)
	# Set up the StartX
	echo '#!/bin/sh 
DESKTOP_SESSION=xfce
export DESKTOP_SESSION
startxfce4
vncserver-virtual -kill $DISPLAY' | sudo tee -a /etc/vnc/xstartup.custom
	sudo chmod 755 /etc/vnc/xstartup.custom

	# Any message to display post all selected installs and configs.  Listed in a end summary.
	POSTMSG[${COUNT}]="${FUNCNAME} "
}

wine () {
	DISTRO=`lsb_release  -i | awk '{print $3}' | tr '[:upper:]' '[:lower:]'`
	CODE_NAME=`lsb_release  -c | awk '{print $2}' | tr '[:upper:]' '[:lower:]'`
	# Install dependances
	sudo apt install software-properties-common zenity cabextract
	# Add the i386 arch
	sudo dpkg --add-architecture i386
	# Add the wine repo
	wget -nc https://dl.winehq.org/wine-builds/winehq.key && sudo apt-key add winehq.key
	sudo apt-add-repository 'deb https://dl.winehq.org/wine-builds/'${DISTRO}'/ '${CODE_NAME}' main'
	sudo add-apt-repository ppa:cybermax-dexter/sdl2-backport
	# Install 4.21
	sudo apt install --install-recommends winehq-devel
	# Install WineTricks
	sudo apt install winetricks

	# Any message to display post all selected installs and configs.  Listed in a end summary.
	POSTMSG[${COUNT}]="${FUNCNAME} "
}

wine-chromebook () {
	DISTRO=`lsb_release  -i | awk '{print $3}' | tr '[:upper:]' '[:lower:]'`
	CODE_NAME=`lsb_release  -c | awk '{print $2}' | tr '[:upper:]' '[:lower:]'`
	# Install dependances
	sudo apt install software-properties-common zenity cabextract
	# Add the i386 arch
	sudo dpkg --add-architecture i386
	# Add the wine repo
	sudo apt-add-repository https://dl.winehq.org/wine-builds/debian/
	# Install 4.21
	sudo apt install --install-recommends winehq-stable
	# Install WineTricks
	wget -O- -q https://download.opensuse.org/repositories/Emulators:/Wine:/Debian/Debian_10/Release.key | sudo apt-key add -
	echo "deb http://download.opensuse.org/repositories/Emulators:/Wine:/Debian/Debian_10 ./" | sudo tee /etc/apt/sources.list.d/wine-obs.list
	sudo apt update
	sudo apt install --install-recommends winehq-stable
	wget  https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks
	chmod +x winetricks

	# Any message to display post all selected installs and configs.  Listed in a end summary.
	POSTMSG[${COUNT}]="${FUNCNAME} "
}

libdvd () {
	sudo apt install libdvd-pkg
	sudo dpkg-reconfigure libdvd-pkg

	# Any message to display post all selected installs and configs.  Listed in a end summary.
	POSTMSG[${COUNT}]="${FUNCNAME} "
}

google-drive () {
	if [[ ${BUILD} = "DEBIAN" ]]; then
		sudo apt install software-properties-common dirmngr
		sudo echo deb http://ppa.launchpad.net/alessandro-strada/ppa/ubuntu xenial main >> /etc/apt/sources.list.d/alessandro-strada-ubuntu-ppa-bionic.list
		sudo echo deb-src http://ppa.launchpad.net/alessandro-strada/ppa/ubuntu xenial main >> /etc/apt/sources.list.d/alessandro-strada-ubuntu-ppa-bionic.list
		sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys AD5F235DF639B041
	elif [[ ${BUILD} = "UBUNTU" ]]; then
		sudo add-apt-repository ppa:alessandro-strada/ppa
	else
		# Not sure what, so we will try the basic Ubuntu packages
		sudo add-apt-repository ppa:alessandro-strada/ppa
	fi
	sudo apt update
	sudo apt install google-drive-ocamlfuse
	google-drive-ocamlfuse

	# Any message to display post all selected installs and configs.  Listed in a end summary.
	POSTMSG[${COUNT}]="${FUNCNAME}: Create a directory and mount with google-drive-ocamlfuse with: \n\t mkdir ~/gdrive \n\t google-drive-ocamlfuse ~/gdrive)"
}

qemu-virtmanager () {
	# Install Qemu and Virt-Manager
	install -y bridge-utils
	install -y qemu-kvm qemu-system virt-manager virt-viewer libvirt-daemon libvirt-daemon-system libvirt-clients
	
	# Create a link to images in the local user's home
	ln -s /var/lib/libvirt/images ${HOME}/images

	# Any message to display post all selected installs and configs.  Listed in a end summary.
	POSTMSG[${COUNT}]="${FUNCNAME}: Reboot before running Qemu or Virt-Manager. "
}

xo-installer () {
	git clone https://github.com/ronivay/XenOrchestraInstallerUpdater.git

	# Any message to display post all selected installs and configs.  Listed in a end summary.
	POSTMSG[${COUNT}]="${FUNCNAME} "
}

ham-ax25 () {
	# Install AX.25 tools
	echo "Installing and configuring AX.25 tools"
	sudo apt -y install ax25-tools ax25-apps
	sudo systemctl start ax25
	sudo systemctl enable ax25

	# Any message to display post all selected installs and configs.  Listed in a end summary.
	POSTMSG[${COUNT}]="${FUNCNAME} "
}

ham-direwolf () {
	# Direwolf
	echo "Installing and configuring Direwolf"
	sudo apt -y install direwolf
	gunzip -c /usr/share/doc/direwolf/conf/direwolf.conf.gz > ~/direwolf.conf

	# Any message to display post all selected installs and configs.  Listed in a end summary.
	POSTMSG[${COUNT}]="${FUNCNAME}: Edit and config ~/direwolf.conf"
}

ham-xastir () {
	# Xastir
	echo "Installing and configuring Xastir"
	sudo apt -y install xastir
	sudo usermod -a -G xastir-ax25 $USER

	# Any message to display post all selected installs and configs.  Listed in a end summary.
	POSTMSG[${COUNT}]="${FUNCNAME} "
}

ham-yaac () {
	# YAAC
	yaacPath=${HOME}
	echo "Installing and configuring Xastir"
	sudo apt -y install default-jre
	wget https://www.ka2ddo.org/ka2ddo/YAAC.zip
	mkdir -p $yaacPath/YAAC
	unzip -d $yaacPath/YAAC YAAC.zip
	echo -e '#!/usr/bin/bash \n\njava -jar YAAC.jar' > $yaacPath/yaac
	chmod 774 $yaacPath/yaac
	echo "[Desktop Entry]
Version=1.0
Type=Application
Name=YAAC
Comment=Yet Another APRS Client
Exec=java -jar ${yaacPath}/YAAC/YAAC.jar
Icon=${yaacPath}/YAAC/images/yaaclogo64.ico
Path=
Terminal=false
StartupNotify=false" > $yaacPath/YAAC.desktop
	rm YAAC.zip

	# Any message to display post all selected installs and configs.  Listed in a end summary.
	POSTMSG[${COUNT}]="${FUNCNAME}: Run YAAC with the bash script file \n\t ${yaacPath}/yaac"
}

ham-ken-thd72 () {
	# Kenwood TH-D72 Configuration
	echo "Installing additional Kenwood TH-D72 tools"
	sudo apt -y install tmd710-tncsetup
	sudo usermod -a -G dialout $USER
	sudo usermod -a -G tty $USER

	# Any message to display post all selected installs and configs.  Listed in a end summary.
	POSTMSG[${COUNT}]="${FUNCNAME}: Please reboot to fully restart service"
}

ham-pat () {
	# Pat
	downloadLink=`wget -O - https://github.com/la5nta/pat/releases|grep amd64.deb |head -1 | grep strong | awk -F '"' '{ print $2}'`
	wget $downloadLink
	sudo dpkg -i pat_*_linux_amd64.deb
	sudo /usr/share/pat/ax25/install-systemd-ax25-unit.bash

	# Any message to display post all selected installs and configs.  Listed in a end summary.
	POSTMSG[${COUNT}]="${FUNCNAME}: Edit and config \n\t ~/.config/pat/config.json \n\t /etc/ax25/axports"
}

ham-clock () {
	sudo apt -y install make g++ libx11-dev xserver-xorg raspberrypi-ui-mods lightdm lxsession
	cd ~
	rm -fr ESPHamClock
	curl -O https://www.clearskyinstitute.com/ham/HamClock/ESPHamClock.zip
	unzip ESPHamClock.zip
	cd ESPHamClock

	echo "How many CPU cores do you wish to use (1-4, PiZero should be 1)?"
	read cpuCores
	echo " "
	echo "Please copy/paste a target, such as hamclock-1600x960"
	make
	read targetSize

	make -j ${cpuCores} ${targetSize}
	sudo make install

	# Any message to display post all selected installs and configs.  Listed in a end summary.
	POSTMSG[${COUNT}]="${FUNCNAME} "
}


######################################################################
# MAIN
######################################################################

# Get the size of the current terminal window
#eval `resize`

# Check to make sure whiptail is installed and available, if not install it.
if hash whiptail 2>/dev/null; then
	# It's installed, there is nothing to do... continue on.
	echo ""
else
	# Not installed, or we can't find it, so let's prompt to install it
	echo "Bummer, whiptail is required for the menu of install options."
	read -p "Would you like to install whiptail now (y/n)? "
	case $(echo $REPLY | tr '[A-Z]' '[a-z]') in
		y|yes) sudo apt update; sudo apt install -y whiptail ;;
		*)     echo "OK, we shall skip it, but things will not work :-(" ;;
	esac
fi

# Check how big the current screen/terminal is
# LINES=`tput lines`
# COLUMNS=`tput cols`
HEIGHT=`stty size | cut -d" " -f1`
WIDTH=`stty size | cut -d" " -f2`

declare -a SELECTION

# OK, this is a little tricky...
#   but I've added a left and right () before and after so the variable is
#   interperated as an array.
#
#   example of a possible value
#             $SELECTION=(create-alias update-upgrade options ssh-config)
SELECTION=( $(whiptail --title "Post Install on Debian Based Architecture - ${VERSION}" --checklist --separate-output \
	"What post install activities would you like to run on ${BUILD} ${RELEASE} (${CODENAME})?" ${HEIGHT} ${WIDTH} $((HEIGHT-8)) \
	"set-bashrc"        "Create common alias in .bashrc " OFF \
	"update-upgrade"    "Update and upgrade core system " OFF \
	"build-essentials"  "Install: build-essential module-assistant dkms " OFF \
	"essentials"        "Install: basic utilities - vim, networking, monitoring, tools, and misc." OFF \
	"optionals"         "Install: rdesktop iftop ircii ubuntu-restricted-extras" OFF \
	"gui-software"      "Install: GUI Pinta, AppImageLauncher, Color Picker, KeepassXC" OFF \
	"qemu-guest"        "Install: Guest tools for qemu/kvm " OFF \
	"wallpapers"        "Install: A bunch of Ubuntu wallpapers" OFF \
	"xfce-goodies"      "Install: xfce-goodies and plank" OFF \
	"brave-browser"     "Install: Brave browser " OFF \
	"google-chrome"     "Install: Google Chrome browser " OFF \
	"google-drive"	    "Install: Google Drive using OCamlFUSE " OFF \
	"calibre"           "Install: Calibre ebook organizer " OFF \
	"realtek-wifi"      "Install: Realtek AC1200 wifi drivers (rtl88x2BU) " OFF \
	"realvnc"           "Install: RealVNC files" OFF \
	"realvnc-xfce4-add" "Install: Configure XFCE4 startup for use with RealVNC (for older versions, pre 2021)" OFF \
	"qemu-virtmanager"  "Install: Qemu and Virt-Manager " OFF \
	"tor"               "Install: TOR Browser " OFF \
	"expressvpn"        "Install: Express VPN " OFF \
	"kernel-latest"     "Install: Latest Ubuntu kernel v5.4.6 (will reboot) " OFF \
	"wine"		    "Install: Wine & Winetricks" OFF \
	"wine-chromebook"   "Install: Wine & Winetricks on a Chromebook" OFF \
	"libdvd"	    "Install: Install and configure libdvd-pkg for copy protected DVDs" OFF \
	"xo-installer"      "Install: XenOrchestraInstallerUpdater" OFF \
	"ham-ax25"          "Install: Ham: AX.25 tools" OFF \
	"ham-direwolf"      "Install: Ham: Direwolf" OFF \
	"ham-yaac"          "Install: Ham: YAAC" OFF \
	"ham-xastir"        "Install: Ham: Xastir" OFF \
	"ham-ken-thd72"     "Install: Ham: Kenwood TH-D72 Tools" OFF \
	"ham-pat"           "Install: Ham: Pat Winlink" OFF \
	"ham-clock"         "Install: Ham: HamClock" OFF \
	"ssh-config"        "set up SSH keys in .ssh " OFF \
	"create-swap"       "GCP: Create swap space on a Micro compute " OFF \
	"google-remote"     "GCP: install Google Remote " OFF \
	"xfce-gcloud"       "GCP: install xfce4 for GCP compute " OFF \
	"lamp"		    "GCP: install LAMP 7.0 (Linux, Apache, MariaDB, PHP) on GCP " OFF \
	"lap-no-m"	    "GCP: install LAP(no MySQL) 7.3 (Linux, Apache, PHP, MySQL Connectors only) on GCP " OFF \
	"clean-up"          "Clean up everything " OFF \
	3>&1 1>&2 2>&3) )

# Loop through all the returned selections, which is stored in an array $SELECTION
# We need a counter to assign to the POSTMSG array
COUNT=0
for i in "${SELECTION[@]}"
do
	$i $COUNT
	((COUNT=COUNT+1))
done

# Show all the functions that were run, and any post message
# Now we need a counter to just number the summary... nothing about the above COUNT
COUNT=1
echo
echo "Well this is exciting, we have installed and configured the following:"
for i in "${POSTMSG[@]}"
do
	echo -e $COUNT. $i
	((COUNT=COUNT+1))
done

