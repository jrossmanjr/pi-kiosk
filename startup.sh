#!/bin/bash
xset -dpms      				 # disable DPMS (Energy Star) features.
xset s off       				 # disable screen saver
xset s noblank   				 # dont blank the video device
matchbox-window-manager &  		 # Start the Window Manager
unclutter &						 # hide the mouse
