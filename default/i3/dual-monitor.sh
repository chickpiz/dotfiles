#!/bin/sh

xrandr --output HDMI-2 --mode 2560x1440 --pos 0x0 --rotate right --output HDMI-1 --primary --mode 2560x1440 --pos 1440x661 --rotate normal --output DP-1-1 --off --output HDMI-1-3 --off --output DP-1-2 --off --output DP-1-3 --off --output None-1-1 --off
feh --bg-max $(find $HOME/Pictures/left/ -name "*.jpg" | shuf -n1) --bg-max $(find $HOME/Pictures/right/ -name "*.jpg" | shuf -n1)
picom --config /home/jwhur/.config/i3/picom/picom.conf
