#!/bin/bash
set -e

sudo cron &

if [[ -z "$VNC_PASS" ]]; then
  echo "VNC_PASS not set!"
  exit 1
fi

echo "=========================================="
echo "Starting LXQt Container with XWayland"
echo "User: $(whoami) (UID: $(id -u))"
echo "=========================================="

export DISPLAY=:99
export RESOLUTION=1920x1080x24

echo "Starting Xvfb..."
Xvfb $DISPLAY -screen 0 ${RESOLUTION} -ac +extension GLX +render -noreset > /tmp/xvfb.log 2>&1 &
XVFB_PID=$!

sleep 3

if ! ps -p $XVFB_PID > /dev/null; then
  echo "ERROR: Xvfb failed to start"
  cat /tmp/xvfb.log
  exit 1
fi

echo "✓ Xvfb started successfully on display $DISPLAY"

echo "Starting D-Bus session..."
eval $(dbus-launch --sh-syntax)
export DBUS_SESSION_BUS_ADDRESS
export DBUS_SESSION_BUS_PID

echo "Starting Openbox window manager..."
openbox > /tmp/openbox.log 2>&1 &
OPENBOX_PID=$!

sleep 2

if ! ps -p $OPENBOX_PID > /dev/null; then
  echo "WARNING: Openbox may have backgrounded"
  cat /tmp/openbox.log
fi

echo "✓ Openbox started"

echo "Starting LXQt..."
startlxqt > /tmp/lxqt.log 2>&1 &
LXQT_PID=$!

sleep 5

if ! ps -p $LXQT_PID > /dev/null; then
  echo "WARNING: LXQt may have backgrounded, checking processes..."
  cat /tmp/lxqt.log
fi

echo "✓ LXQt session started"

sleep 3

echo "Starting x11vnc..."
x11vnc -display $DISPLAY -forever -shared -rfbport 5900 -nopw -xkb > /tmp/x11vnc.log 2>&1 &
X11VNC_PID=$!

sleep 3

if ! ps -p $X11VNC_PID > /dev/null; then
  echo "ERROR: x11vnc failed to start"
  cat /tmp/x11vnc.log
  exit 1
fi

if ss -tuln | grep -q ':5900'; then
  echo "✓ x11vnc started successfully on port 5900"
else
  echo "WARNING: x11vnc not listening on port 5900"
  cat /tmp/x11vnc.log
fi

if command -v /usr/share/novnc/utils/novnc_proxy >/dev/null 2>&1; then
  echo "Starting noVNC..."
  /usr/share/novnc/utils/novnc_proxy --web /usr/share/novnc --vnc localhost:5900 --listen 6080 > /tmp/novnc.log 2>&1 &
  sleep 2
  
  if ss -tuln | grep -q ':6080'; then
    echo "✓ noVNC started on port 6080"
  else
    echo "ERROR: noVNC failed to bind to port 6080"
    cat /tmp/novnc.log
  fi
fi

echo ""
echo "=========================================="
echo "✓ Setup complete!"
echo "=========================================="
echo "VNC Access:    localhost:5900"
echo "Web Access:    http://localhost:6080"
echo "Desktop:       LXQt on X11 (via Xvfb)"
echo "Display:       $DISPLAY"
echo "Resolution:    $RESOLUTION"
echo "=========================================="
echo ""
echo "Monitoring logs..."

tail -f /tmp/*.log &

wait
