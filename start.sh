#!/bin/bash
set -e

export DISPLAY=:0

if [[ -z "$VNC_PASS" ]]; then
  echo "VNC_PASS not set!"
  exit 1
fi

mkdir -p $HOME/.vnc
x11vnc -storepasswd $VNC_PASS $HOME/.vnc/passwd

Xvfb :0 -screen 0 1920x1080x24 > /tmp/xvfb.log 2>&1 &
sleep 2
lxsession > /tmp/lxsession.log 2>&1 &
obs > /tmp/obs.log 2>&1 &

x11vnc -display :0 -rfbauth $HOME/.vnc/passwd -forever -shared > /tmp/x11vnc.log 2>&1 &
/usr/share/novnc/utils/novnc_proxy --vnc localhost:5900 --listen 6080 > /tmp/novnc.log 2>&1 &

wait
