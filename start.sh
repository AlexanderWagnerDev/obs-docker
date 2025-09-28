#!/bin/bash

export DISPLAY=:0
Xvfb :0 -screen 0 1280x720x24 &
sleep 2
lxsession &
obs &
mkdir -p $HOME/.vnc
x11vnc -storepasswd $VNC_PASS $HOME/.vnc/passwd
x11vnc -display :0 -rfbauth $HOME/.vnc/passwd -forever -shared &
/usr/share/novnc/utils/novnc_proxy --vnc localhost:5900 --listen 6080 &
wait
