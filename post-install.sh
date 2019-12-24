#!/bin/bash

# Created by Chris Jackson, cdjackson14@gmail.com
# Can be used on many Debian based installs, like Ubuntu, Raspberry Pi, Kali, and GCP Linux computes
#
# Top is all functions, the bottom lines contain the menu and action.





##############################
# FUNCTIONS
##############################

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

lap () {
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
	TOR_LINK=https://www.torproject.org/dist/torbrowser/9.0.2/tor-browser-linux64-9.0.2_en-US.tar.xz
	TOR_FILE=tor-browser-linux64-9.0.2_en-US.tar.xz
	wget $TOR_LINK
	tar -xf $TOR_FILE
	rm $TOR_FILE
}

realvnc-xfce4 () {
	# Check	is wanting 64 or 32 bit
        if [[ $(getconf LONG_BIT) = "64" ]]
        then
		VNCSERVER=VNC-Server-6.4.1-Linux-x64.deb
		VNCVIEWER=VNC-Viewer-6.19.325-Linux-x64.deb
        else
		VNCSERVER=VNC-Server-6.4.1-Linux-x86.deb
		VNCVIEWER=VNC-Viewer-6.19.325-Linux-x86.deb
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
	sudo vnclicense -add 4326B-7H7LA-RG5F2-292D5-9LTTA
	# Set up a nice alias for starting up with multiple resolutions
	echo "alias vv='vncserver :28 -geometry 1280x800 -randr 1280x800,1024x768,1920x1080,1280x1024,1600x1200,1440x900,1600x900,2880x1800,1680x1050'" >> ~/.bashrc
	# Remove the install files
	rm $VNCSERVER
	rm $VNCVIEWER
}



######################################################################
# MAIN
######################################################################

# Get the size of the current terminal window
#eval `resize`
LINES=`tput lines`
COLUMNS=`tput cols`

declare -a SELECTION

# OK, this is a little tricky...
#   but I've added a left and right () before and after so the variable is
#   interperated as an array.
#
#   example of a possible value
#             $SELECTION=(create-alias update-upgrade options ssh-config)
SELECTION=( $(whiptail --title "Post Install on Debian" --checklist --separate-output \
	"What post install activities would you like to run?" $LINES $COLUMNS $((LINES-8)) \
	"create-alias"      "Create common alias in .bashrc " OFF \
	"update-upgrade"    "Update and upgrade core system " OFF \
	"build-essentials"  "Install: build-essential module-assistant dkms " OFF \
	"essentials"        "Install: basic utilities " OFF \
	"optionals"         "Install: rdesktop iftop ircii ubuntu-wallpapers* ubuntu-restricted-extras " OFF \
	"xfce-goodies"      "Install: xfce-goodies " OFF \
	"google-chrome"     "Install: Google Chrome browser " OFF \
	"realtek-wifi"      "Install: Realtek AC1200 wifi drivers " OFF \
	"realvnc-xfce4"     "Install: RealVNC debian files and configure for XFCE4 startup " OFF \
	"tor"               "Install: TOR Browser " OFF \
	"ssh-config"        "set up SSH keys in .ssh " OFF \
	"create-swap"       "GCP: Create swap space on a Micro compute " OFF \
	"google-remote"     "GCP: install Google Remote " OFF \
	"xfce-gcloud"       "GCP: install xfce4 for GCP compute " OFF \
	"lamp"		    "GCP: install LAMP (Linux, Apache, MariaDB, PHP) on GCP " OFF \
	"lap"		    "GCP: install LAP(m) (Linux, Apache, PHP, MySQL Connectors only) on GCP " OFF \
	"clean-up"          "Clean up everything " OFF \
	3>&1 1>&2 2>&3) )

# Now loop through all the returned selections, which is stored in an array $SELECTION
for i in "${SELECTION[@]}"
do
	$i
done
