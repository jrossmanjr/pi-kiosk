#!/bin/bash

#
# source: https://raspberrypi.stackexchange.com/questions/1719/x11-connection-rejected-because-of-wrong-authentication
#
touch /root/.Xauthority
xauth merge /home/pi/.Xauthority
export XAUTHORITY=/root/.Xauthority