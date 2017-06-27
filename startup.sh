#!/bin/sh

vncserver -kill :1
vncserver -kill :2

vncserver :1 -xstartup ~/.xinitrc.d/stumpwm
vncserver :2 -xstartup ~/.xinitrc.d/lxde

echo "IP addr: $(hostname -i)"
echo "Started server at :1 for StumpWM"
echo "Started server at :2 for LXDE"

exec /bin/bash
