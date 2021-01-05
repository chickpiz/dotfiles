 #!/bin/bash -e

# Terminate already running bar instances
killall -q polybar

if type "xrandr"; then
  for m in $(xrandr --query | grep " connected" | cut -d" " -f1); do
    MONITOR=$m polybar --config=$HOME/.config/i3/polybar/config --reload top &
  done
else
  polybar --config=$HOME/.config/i3/polybar/config --reload top &
fi
