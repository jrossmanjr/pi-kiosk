#!/usr/bin/env bash
# Kiosk mode Install Script
# data on how to do this was pulled mainly from < https://die-antwort.eu/techblog/2017-12-setup-raspberry-pi-for-kiosk-mode/ >
# data on how to refresh the screen - < https://www.raspberrypi.org/forums/viewtopic.php?t=178206#p1300301 >

# Run this script as root or under sudo
screen_size=$(stty size 2>/dev/null || echo 24 80)
rows=$(echo $screen_size | awk '{print $1}')
columns=$(echo $screen_size | awk '{print $2}')

# Divide by two so the dialogues take up half of the screen, which looks nice.
r=$(( rows / 2 ))
c=$(( columns / 2 ))
# Unless the screen is tiny
r=$(( r < 20 ? 20 : r ))
c=$(( c < 70 ? 70 : c ))

if [[ $EUID -eq 0 ]];then
  echo "::: You are root."
else
  echo "::: sudo will be used."
  # Check if it is actually installed
  # If it isn't, exit because the install cannot complete
  if [[ $(dpkg-query -s sudo) ]];then
    export SUDO="sudo"
  else
    echo "::: Please install sudo or run this script as root."
    exit 1
  fi
fi

whiptail --msgbox --title "Pi-Kiosk automated installer" "\nThis installer turns your Raspberry Pi and Wifi Dongle into \nan awesome kiosk or webpage displayer!" ${r} ${c}

whiptail --msgbox --title "Pi-Kiosk automated installer" "\n\nFirst things first... Lets set up some variables!" ${r} ${c}

var1=$(whiptail --inputbox "Webpage to show" ${r} ${c} http://192.168.XX.XX:XXXX --title "Kiosk Display Selection" 3>&1 1>&2 2>&3)

var2=$(whiptail --inputbox "Kiosk name --> hostname" ${r} ${c} kiosk --title "Kiosk name" 3>&1 1>&2 2>&3)

whiptail --msgbox --title "Pi-Kiosk automated installer" "\n\nOk all the data has been entered...The install will now complete!" ${r} ${c}

function update_distro() {
  #updating the distro...
  echo ":::"
  echo "::: Running an update to your distro :::"
  $SUDO apt update
  echo "::: DONE! :::"
}

function upgrade_distro() {
  #updating the distro...
  echo "::::::::::::"
  echo "::: Running upgrades :::"
  $SUDO apt upgrade -y
  echo "::: DONE! :::"
}

function install_wifi() {
  # installing wifi drivers
  echo "::::::::::::"
  echo "::: Installing wifi drivers :::"
  $SUDO wget http://www.fars-robotics.net/install-wifi -O /usr/bin/install-wifi
  $SUDO chmod +x /usr/bin/install-wifi
  $SUDO install-wifi
  echo "::: DONE! :::"
}

function install_the_things() {
  # installing all the programs to enable kiosk mode
  echo "::::::::::::"
  echo "::: Installing programs :::"
  $SUDO apt install -y xinit xserver-xorg x11-xserver-utils unclutter chromium-browser matchbox-window-manager xdotool
  echo "::: DONE installing all the things!"
}

function edit_startup() {
  # editing startup files to auto start
  echo ":::"
  echo "::: Editing Files :::"
  echo "chromium-browser  --no-sandbox --noerrdialogs --disable-infobars --incognito --kiosk $var1
/home/pi/pi-kiosk/xauth_root.sh
/home/pi/pi-kiosk/autorefresh-chromium.sh" | sudo tee --append startup.sh > /dev/null
  
  # make the startup executeable
  chmod +x startup.sh
  
  # change rc.local to run the startup script
  $SUDO sed -i.bak "s+exit 0+#exit 0+g" /etc/rc.local
  echo 'sudo xinit ./home/pi/pi-kiosk/startup.sh &' | sudo tee --append /etc/rc.local > /dev/null
  echo 'exit 0 ' | sudo tee --append /etc/rc.local > /dev/null

  # get xinit to run matchbox
  $SUDO touch ~/.xinitrc
  echo '#!/bin/bash
matchbox-window-manager' | sudo tee --append ~/.xinitrc > /dev/null

  # change the hostname
  $SUDO echo $var2 > /etc/hostname # changes the hostname of the machine

  # setup a xdotool to be allwed to run in root
  sudo chmod 755 xauth_root.sh

  # setup the auto refresh script
  sudo chmod 755 autorefresh-chromium.sh

  echo "::: DONE :::"
  echo "::: PLEASE RESTART :::"
  #sleep 5
  #$SUDO reboot
}

update_distro
upgrade_distro
install_wifi
install_the_things
edit_startup
