#!/bin/bash

#
# also see instructions here: https://www.raspberrypi.org/forums/viewtopic.php?t=178206#p1239241
#
# To make this run with sudo (which is the case when run at boot), execute "xauth_root.sh" before running this script.
#
# xdotools setup instructions found here: http://theembeddedlab.com/tutorials/simulate-keyboard-mouse-events-xdotool-raspberry-pi/
#

# This will only set up the DISPLAY variable for one command
DISPLAY=:0 xdotool key "ctrl+F5"

# This will set up the DISPLAY variable for every command executed on this terminal,
# and child processes spawned from this terminal
export DISPLAY=:0

while true; #create an infinite loop
do
  xdotool key "ctrl+F5" &
  sleep 5400 #refresh time in seconds so 5400 = every 3 hrs
done