#!/bin/bash

# Created by Chris Jackson, cdjackson14@gmail.com
# Can be used on many Debian based installs, like Ubuntu, Raspberry Pi, Kali, and GCP Linux computes
#
# Top is all functions, the bottom lines contain the menu and action.
VERSION=2.23
BUILD=`lsb_release -i | awk {'print $3'} | tr '[:upper:]' '[:lower:]'`
RELEASE=`lsb_release -r | awk {'print $2'}`
CODENAME=`lsb_release -c | awk {'print $2'} | tr '[:upper:]' '[:lower:]'`

##############################
# FUNCTIONS
##############################

create-alias () {
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
	sudo apt install -y htop net-tools nmon ssh screen emacs sshfs cmatrix vlc mplayer rtorrent screen exiv2 git exfat-utils cifs-utils
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
	sudo apt -y install libapache2-mod-php7.0 php7.0 php7.0-gd php7.0-xml php7.0-curl php7.0-mbstring php7.0-mcrypt php7.0-xmlrpc
	# MySQL PHP connector only
	sudo apt install php7.0-mysql
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
	# Install the TOR Browser on Linux
	TOR_FILE=tor-browser-linux64-9.0.9_en-US.tar.xz
	TOR_LINK=https://dist.torproject.org/torbrowser/9.0.9/${TOR_FILE}
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
	BASE_URL=https://download.expressvpn.xyz/clients/linux
	FILE_1=expressvpn_2.4.1-1_amd64.deb
	wget ${BASE_URL}/${FILE_1}
	sudo dpkg -i ${FILE_1}
	echo Please log into your account and get the activiation code.
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

realvnc-xfce4 () {
	# Check	is wanting 64 or 32 bit
        if [[ $(getconf LONG_BIT) = "64" ]]
        then
		VNCSERVER=VNC-Server-6.7.1-Linux-x64.deb
		VNCVIEWER=VNC-Viewer-6.20.113-Linux-x64.deb
        else
		VNCSERVER=VNC-Server-6.7.1-Linux-x86.deb
		VNCVIEWER=VNC-Viewer-6.20.113-Linux-x86.deb
        fi
	# Download the RealVNC files
	wget https://www.realvnc.com/download/file/vnc.files/$VNCSERVER
	wget https://www.realvnc.com/download/file/viewer.files/$VNCVIEWER
	
	# Install both
	sudo dpkg --install $VNCSERVER
	sudo apt install -f -y
	sudo dpkg --install $VNCVIEWER
	sudo apt install -f -y

	# Set up the StartX
	echo '#!/bin/sh 
DESKTOP_SESSION=xfce
export DESKTOP_SESSION
startxfce4
vncserver-virtual -kill $DISPLAY' | sudo tee -a /etc/vnc/xstartup.custom
	sudo chmod 755 /etc/vnc/xstartup.custom
	
	# Register the license
	read -p "Would you like to add the VNC license (y/n)? "
	case $(echo $REPLY | tr '[A-Z]' '[a-z]') in
		y|yes) sudo vnclicense -add 4326B-7H7LA-RG5F2-292D5-9LTTA ;;
		*)     echo "OK, we shall skip it." ;;
	esac
	# Set up a nice alias for starting up with multiple resolutions
	echo "alias vv='vncserver :28 -geometry 1280x800 -randr 1280x800,1024x768,1920x1080,1280x1024,1600x1200,1440x900,1600x900,2880x1800,1680x1050'" >> ~/.bashrc
	#
	sudo vnclicense -add 4326B-7H7LA-RG5F2-292D5-9LTTA
	
	# Remove the install files
	rm $VNCSERVER
	rm $VNCVIEWER
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
	if [[ ${BUILD} = "debian" ]]; then
		sudo apt install software-properties-common dirmngr
		sudo echo deb http://ppa.launchpad.net/alessandro-strada/ppa/ubuntu xenial main >> /etc/apt/sources.list.d/alessandro-strada-ubuntu-ppa-bionic.list
		sudo echo deb-src http://ppa.launchpad.net/alessandro-strada/ppa/ubuntu xenial main >> /etc/apt/sources.list.d/alessandro-strada-ubuntu-ppa-bionic.list
		sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys AD5F235DF639B041
	elif [[ ${BUILD} = "ubuntu" ]]; then
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
LINES=`tput lines`
COLUMNS=`tput cols`

declare -a SELECTION

# OK, this is a little tricky...
#   but I've added a left and right () before and after so the variable is
#   interperated as an array.
#
#   example of a possible value
#             $SELECTION=(create-alias update-upgrade options ssh-config)
SELECTION=( $(whiptail --title "Post Install on Debian - ${VERSION}" --checklist --separate-output \
	"What post install activities would you like to run on your Debian OS?" $LINES $COLUMNS $((LINES-8)) \
	"create-alias"      "Create common alias in .bashrc " OFF \
	"update-upgrade"    "Update and upgrade core system " OFF \
	"build-essentials"  "Install: build-essential module-assistant dkms " OFF \
	"essentials"        "Install: basic utilities - network, emacs, and mount tools" OFF \
	"optionals"         "Install: rdesktop iftop ircii ubuntu-wallpapers* ubuntu-restricted-extras " OFF \
	"xfce-goodies"      "Install: xfce-goodies " OFF \
	"google-chrome"     "Install: Google Chrome browser " OFF \
	"google-drive"	    "Install: Google Drive using OCamlFUSE " OFF \
	"realtek-wifi"      "Install: Realtek AC1200 wifi drivers (rtl88x2BU) " OFF \
	"realvnc-xfce4"     "Install: RealVNC files and configure for XFCE4 startup " OFF \
	"tor"               "Install: TOR Browser " OFF \
	"expressvpn"        "Install: Express VPN " OFF \
	"kernel-latest"     "Install: Latest Ubuntu kernel v5.4.6 (will reboot) " OFF \
	"wine"		    "Install: Wine & Winetricks" OFF \
	"wine-chromebook"   "Install: Wine & Winetricks on a Chromebook" OFF \
	"libdvd"	    "Install: Install and configure libdvd-pkg for copy protected DVDs" OFF \
	"ssh-config"        "set up SSH keys in .ssh " OFF \
	"create-swap"       "GCP: Create swap space on a Micro compute " OFF \
	"google-remote"     "GCP: install Google Remote " OFF \
	"xfce-gcloud"       "GCP: install xfce4 for GCP compute " OFF \
	"lamp"		    "GCP: install LAMP (Linux, Apache, MariaDB, PHP) on GCP " OFF \
	"lap-no-m"	    "GCP: install LAP(no MySQL) (Linux, Apache, PHP, MySQL Connectors only) on GCP " OFF \
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
