#!/usr/bin/env bash

killall polybar
for m in $(xrandr --query | grep " connected" | cut -d" " -f1); do
  MONITOR=$m polybar --reload -c ~/.config/i3/polybar.ini i3wm &
done
