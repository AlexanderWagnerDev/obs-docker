#!/bin/bash
set -e

sudo cron &

if [[ -z "$VNC_PASS" ]]; then
  echo "VNC_PASS not set!"
  exit 1
fi

echo "=========================================="
echo "Starting LXQt Container with Weston"
echo "User: $(whoami) (UID: $(id -u))"
echo "=========================================="

export XDG_RUNTIME_DIR=/tmp/runtime-$(id -u)
export WAYLAND_DISPLAY=wayland-0

mkdir -p $XDG_RUNTIME_DIR
chmod 700 $XDG_RUNTIME_DIR

echo "Starting D-Bus session..."
eval $(dbus-launch --sh-syntax)
export DBUS_SESSION_BUS_ADDRESS
export DBUS_SESSION_BUS_PID

echo "Starting Weston compositor..."
weston --backend=headless-backend.so --width=1920 --height=1080 > /tmp/weston.log 2>&1 &
WESTON_PID=$!

sleep 5

if ! ps -p $WESTON_PID > /dev/null; then
  echo "ERROR: Weston failed to start"
  echo "=== Weston Log ==="
  cat /tmp/weston.log
  exit 1
fi

echo "Searching for Wayland socket..."
WAYLAND_SOCKET=$(ls -1 $XDG_RUNTIME_DIR/wayland-* 2>/dev/null | grep -v '.lock$' | head -n1)

if [[ -z "$WAYLAND_SOCKET" ]]; then
  echo "ERROR: No Wayland socket found in $XDG_RUNTIME_DIR"
  echo "Available files:"
  ls -la $XDG_RUNTIME_DIR/
  exit 1
fi

export WAYLAND_DISPLAY=$(basename "$WAYLAND_SOCKET")
echo "✓ Found Wayland socket: $WAYLAND_DISPLAY"

if [ ! -S "$WAYLAND_SOCKET" ]; then
  echo "ERROR: $WAYLAND_SOCKET is not a valid socket"
  exit 1
fi

echo "✓ Weston started successfully with display: $WAYLAND_DISPLAY"

export QT_QPA_PLATFORM=wayland
export QT_WAYLAND_DISABLE_WINDOWDECORATION=0

echo "Starting LXQt session..."
startlxqt > /tmp/lxqt.log 2>&1 &
LXQT_PID=$!

sleep 5

if ! ps -p $LXQT_PID > /dev/null; then
  echo "WARNING: LXQt may have backgrounded, checking processes..."
  cat /tmp/lxqt.log
fi

echo "✓ LXQt session started"

sleep 3

echo "Configuring wayvnc..."
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
  echo "ERROR: wayvnc failed to start"
  echo "=== wayvnc Log ==="
  cat /tmp/wayvnc.log
  exit 1
fi

if ss -tuln | grep -q ':5900'; then
  echo "✓ wayvnc started successfully on port 5900"
else
  echo "WARNING: wayvnc not listening on port 5900"
  echo "=== wayvnc Log ==="
  cat /tmp/wayvnc.log
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
echo "Desktop:       LXQt on Wayland (Weston)"
echo "Wayland Display: $WAYLAND_DISPLAY"
echo "=========================================="
echo ""
echo "Monitoring logs..."

tail -f /tmp/*.log &

wait
