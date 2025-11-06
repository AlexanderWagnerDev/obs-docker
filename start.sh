#!/bin/bash
set -e

sudo cron &

if [[ -z "$VNC_PASS" ]]; then
  echo "VNC_PASS not set!"
  exit 1
fi

echo "=========================================="
echo "Starting LXQt Container with Wayfire"
echo "User: $(whoami) (UID: $(id -u))"
echo "=========================================="

export XDG_RUNTIME_DIR=/tmp/runtime-$(id -u)
export WAYLAND_DISPLAY=wayfire-0

mkdir -p $XDG_RUNTIME_DIR
chmod 700 $XDG_RUNTIME_DIR

echo "Starting D-Bus session..."
eval $(dbus-launch --sh-syntax)
export DBUS_SESSION_BUS_ADDRESS
export DBUS_SESSION_BUS_PID

echo "Starting Wayfire..."
wayfire --no-use-wayland --server --width=1920 --height=1080 > /tmp/wayfire.log 2>&1 &
WAYFIRE_PID=$!

sleep 5

WAYLAND_SOCKET=$(ls -1 $XDG_RUNTIME_DIR/wayfire-*.socket 2>/dev/null | head -n1)

if [[ -z "$WAYLAND_SOCKET" ]]; then
  echo "ERROR: Kein Wayfire Socket gefunden."
  exit 1
fi

export WAYLAND_DISPLAY=$(basename "$WAYLAND_SOCKET" .socket)
echo "✓ Gefundener Wayland Socket: $WAYLAND_DISPLAY"

echo "Starting LXQt..."
startlxqt > /tmp/lxqt.log 2>&1 &
LXQT_PID=$!

sleep 5

if ! ps -p $LXQT_PID > /dev/null; then
  echo "WARNING: LXQt Background-Apps oder Fehler..."
  cat /tmp/lxqt.log
fi

echo "✓ LXQt gestartet"

mkdir -p $HOME/.config/wayvnc
cat > $HOME/.config/wayvnc/config << EOF
address=0.0.0.0
enable_auth=false
EOF
chmod 600 $HOME/.config/wayvnc/config

echo "Starting wayvnc..."
wayvnc --disable-input -C $HOME/.config/wayvnc/config 0.0.0.0 5900 > /tmp/wayvnc.log 2>&1 &
WAYVNC_PID=$!

sleep 3

if ! ps -p $WAYVNC_PID > /dev/null; then
  echo "ERROR: wayvnc nicht gestartet"
  cat /tmp/wayvnc.log
  exit 1
fi

echo "Starting noVNC..."
/usr/share/novnc/utils/novnc_proxy --web /usr/share/novnc --vnc localhost:5900 --listen 6080 > /tmp/novnc.log 2>&1 &
sleep 2

if ss -tuln | grep -q ':6080'; then
  echo "✓ noVNC läuft auf Port 6080"
else
  echo "ERROR: noVNC läuft nicht"
  cat /tmp/novnc.log
fi

echo "Setup abgeschlossen!"
echo "VNC: localhost:5900"
echo "Web: http://localhost:6080"
echo "Wayfire auf Wayland: $WAYLAND_DISPLAY"

tail -f /tmp/*.log &

wait
