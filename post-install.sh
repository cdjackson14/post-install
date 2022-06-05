#!/bin/bash

# Created by Chris Jackson, cdjackson14@gmail.com
# Can be used on many Debian based installs, like Ubuntu, Raspberry Pi, Kali, and GCP Linux computes
#
# Top is all functions, the bottom lines contain the menu and action.
VERSION=2.9
# Found that Chromebooks don't have lsb-release install by default, so
# switching to looking in /etc/os-release
#	BUILD=`lsb_release -i | awk {'print $3'} | tr '[:upper:]' '[:lower:]'`
#	RELEASE=`lsb_release -r | awk {'print $2'}`
#	CODENAME=`lsb_release -c | awk {'print $2'} | tr '[:upper:]' '[:lower:]'`
BUILD=`grep ^ID= /etc/os-release | awk -F = '{ print $2 }' | tr '[:lower:]' '[:upper:]'`
RELEASE=`grep ^VERSION_ID= /etc/os-release | awk -F = '{ print $2 }' | sed s/\"//g`
CODENAME=`grep VERSION_CODENAME /etc/os-release | awk -F = '{ print $2 }'`

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
}

create-swap () {
	sudo fallocate -l 1G /swapfile
	sudo dd if=/dev/zero of=/swapfile bs=1024 count=1048576
	sudo chmod 600 /swapfile
	sudo mkswap /swapfile
	sudo swapon /swapfile
	echo '/swapfile swap swap defaults 0 0' | sudo tee -a /etc/fstab
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
	sudo apt install -y htop vim net-tools nmon ssh screen sshfs cmatrix vlc mplayer rtorrent exiv2 git cifs-utils exfatprogs gparted
	sudo apt install -y exfat-utils 
}

optionals () {
	# Added the ~n needed when install wildcards using apt (or I could have fallen back to apt-get)
	sudo apt install -y rdesktop iftop ircii ubuntu-restricted-extras
}

qemu-guest () {
	sudo apt install -y qemu-guest-agent spice-vdagent
	mkdir ~/bin
	echo $'xrandr --output \"$(xrandr | awk \'/ connected/{print $1; exit; }\')\" --auto' > ~/bin/vmresize
	chmod 777 ~/bin/vmresize
}

wallpapers () {
	# Things to install with wildcard (for Ubuntu 20.04+)
	sudo apt install -y '~nubuntu-wallpapers*'
	if [[ $? = 100 ]]
	then
		# Maybe this is not Ubuntu 20+, so fall back to the old behavious of apt
		sudo apt install -y ubuntu-wallpapers*
	fi
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
	# I don't think I really want this... I think this accidently was cut/pasted here many versions ago
	# sudo apt install --assume-yes xscreensaver
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
}

tor () {
	# Find the current version
	TOR_VERSION=`wget -q -O - https://www.torproject.org/download/languages/ | grep 'tor-browser-linux64-' | awk -F '/' '{ print $4;exit }'`

	# Install the TOR Browser on Linux
	TOR_FILE=tor-browser-linux64-${TOR_VERSION}_en-US.tar.xz
	TOR_LINK=https://dist.torproject.org/torbrowser/${TOR_VERSION}/${TOR_FILE}

	# Download, untar, and set up for use
	wget ${TOR_LINK}
	tar -xf ${TOR_FILE}
	rm ${TOR_FILE}
	sudo mv tor-browser_en-US ~/tor-browser
	echo '#!/bin/bash' > ~/tor-browser/copy-to-start-menu.sh 
	echo 'mkdir -p ~/.local/share/applications/' >> ~/tor-browser/copy-to-start-menu.sh
	echo 'cp ~/tor-browser/start-tor-browser.desktop ~/.local/share/applications/' >> ~/tor-browser/copy-to-start-menu.sh
	chmod 777 ~/tor-browser/copy-to-start-menu.sh
}

expressvpn () {
	# BASE_URL=https://www.expressvpn.works/clients/linux
	BASE_URL=https://download.expressvpn.xyz/clients/linux
	FILE_1=expressvpn_3.14.0.4-1_amd64.deb
	wget ${BASE_URL}/${FILE_1}
	sudo dpkg -i ${FILE_1}
	echo Please log into your account and get the activiation code.
	echo :: ERGQ8M5C6PWCOVTJDW9T05Q ::
	echo https://www.expressvpn.com/sign-in
	rm ${FILE_1}
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
}

realvnc () {
	# Determine the latest version
	VNCS_VER=`wget -q -O - https://www.realvnc.com/en/connect/download/vnc/ | grep 'download-link-path' | awk '{ print $3 }' | awk -F '-' '{ print $3 }'`
	VNCV_VER=`wget -q -O - https://www.realvnc.com/en/connect/download/viewer/linux | grep 'x64.deb' | awk -F '-' '{ print $5 }'`

	# Check	is wanting 64 or 32 bit
        if [[ $(getconf LONG_BIT) = "64" ]]
        then
		VNCSERVER=VNC-Server-${VNCS_VER}-Linux-x64.deb
		VNCVIEWER=VNC-Viewer-${VNCV_VER}-Linux-x64.deb
        else
		VNCSERVER=VNC-Server-${VNCS_VER}-Linux-x86.deb
		VNCVIEWER=VNC-Viewer-${VNCV_VER}-Linux-x86.deb
        fi

	# Download the RealVNC files
	wget https://www.realvnc.com/download/file/vnc.files/$VNCSERVER
	wget https://www.realvnc.com/download/file/viewer.files/$VNCVIEWER
	
	# Install both
	sudo dpkg --install $VNCSERVER
	sudo apt install -f -y
	sudo dpkg --install $VNCVIEWER
	sudo apt install -f -y
	
	# Register the license
	read -p "Would you like to add the VNC license (y/n)? "
	case $(echo $REPLY | tr '[A-Z]' '[a-z]') in
		y|yes) sudo vnclicense -add 4326B-7H7LA-RG5F2-292D5-9LTTA ;;
		*)     echo "OK, we shall skip it." ;;
	esac
	# Set up a nice alias for starting up with multiple resolutions
	# echo "alias vv='vncserver :28 -geometry 1280x800 -randr 1280x800,1024x768,1920x1080,1280x1024,1600x1200,1440x900,1600x900,2880x1800,1680x1050'" >> ~/.bashrc
	# sudo vnclicense -add 4326B-7H7LA-RG5F2-292D5-9LTTA
	
	# Remove the install files
	rm $VNCSERVER
	rm $VNCVIEWER
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

}

libdvd () {
	sudo apt install libdvd-pkg
	sudo dpkg-reconfigure libdvd-pkg
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
	echo "Now just create a directory and mount with google-drive-ocamlfuse"
	echo "       $ mkdir ~/gdrive "
	echo "       $ google-drive-ocamlfuse ~/gdrive "
	echo " "
}

xo-installer () {
	git clone https://github.com/ronivay/XenOrchestraInstallerUpdater.git
}

hamclock () {
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
	"qemu-guest"        "Install: Guest tools for qemu/kvm " OFF \
	"wallpapers"        "Install: A bunch of Ubuntu wallpapers" OFF \
	"xfce-goodies"      "Install: xfce-goodies " OFF \
	"google-chrome"     "Install: Google Chrome browser " OFF \
	"google-drive"	    "Install: Google Drive using OCamlFUSE " OFF \
	"realtek-wifi"      "Install: Realtek AC1200 wifi drivers (rtl88x2BU) " OFF \
	"realvnc"           "Install: RealVNC files" OFF \
	"realvnc-xfce4-add" "Install: Configure XFCE4 startup for use with RealVNC (for older versions, pre 2021)" OFF \
	"tor"               "Install: TOR Browser " OFF \
	"expressvpn"        "Install: Express VPN " OFF \
	"kernel-latest"     "Install: Latest Ubuntu kernel v5.4.6 (will reboot) " OFF \
	"wine"		    "Install: Wine & Winetricks" OFF \
	"wine-chromebook"   "Install: Wine & Winetricks on a Chromebook" OFF \
	"libdvd"	    "Install: Install and configure libdvd-pkg for copy protected DVDs" OFF \
	"xo-installer"      "Install: XenOrchestraInstallerUpdater" OFF \
	"hamclock"          "Install: HamClock" OFF \
	"ssh-config"        "set up SSH keys in .ssh " OFF \
	"create-swap"       "GCP: Create swap space on a Micro compute " OFF \
	"google-remote"     "GCP: install Google Remote " OFF \
	"xfce-gcloud"       "GCP: install xfce4 for GCP compute " OFF \
	"lamp"		    "GCP: install LAMP 7.0 (Linux, Apache, MariaDB, PHP) on GCP " OFF \
	"lap-no-m"	    "GCP: install LAP(no MySQL) 7.3 (Linux, Apache, PHP, MySQL Connectors only) on GCP " OFF \
	"clean-up"          "Clean up everything " OFF \
	3>&1 1>&2 2>&3) )

# Now loop through all the returned selections, which is stored in an array $SELECTION
for i in "${SELECTION[@]}"
do
	$i
done

# Let us show what was selected and done... cause sometimes I walk away and forget what I just did
echo
echo "Completed: "
MYCOUNT=0
for i in "${SELECTION[@]}"
do
	((MYCOUNT=MYCOUNT+1))
	echo    ${MYCOUNT}. ${i}
done
