#!/bin/bash
set -e

cron

export XDG_RUNTIME_DIR=/tmp/runtime-root
export WLR_BACKENDS=headless
export WLR_LIBINPUT_NO_DEVICES=1
export WAYLAND_DISPLAY=wayland-0

mkdir -p $XDG_RUNTIME_DIR
chmod 700 $XDG_RUNTIME_DIR

if [[ -z "$VNC_PASS" ]]; then
  echo "VNC_PASS not set!"
  exit 1
fi

sway --unsupported-gpu > /tmp/sway.log 2>&1 &
sleep 3

obs --platform wayland > /tmp/obs.log 2>&1 &
sleep 2

wayvnc -o HEADLESS-1 -p $VNC_PASS 0.0.0.0 5900 > /tmp/wayvnc.log 2>&1 &
sleep 2

/usr/share/novnc/utils/novnc_proxy --vnc localhost:5900 --listen 6080 > /tmp/novnc.log 2>&1 &

echo "Wayland setup complete. Logs available in /tmp/"
tail -f /tmp/*.log &

wait
