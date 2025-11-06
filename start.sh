#!/bin/bash
set -e

sudo cron &

if [[ -z "$VNC_PASS" ]]; then
  echo "VNC_PASS not set!"
  exit 1
fi

echo "=========================================="
echo "Starting OBS Wayland Container with Sway"
echo "User: $(whoami) (UID: $(id -u))"
echo "=========================================="

export XDG_RUNTIME_DIR=/tmp/runtime-$(id -u)
export WLR_BACKENDS=headless
export WLR_LIBINPUT_NO_DEVICES=1
export WLR_RENDERER_ALLOW_SOFTWARE=1

mkdir -p $XDG_RUNTIME_DIR
chmod 700 $XDG_RUNTIME_DIR

echo "Starting Sway compositor..."
sway --unsupported-gpu > /tmp/sway.log 2>&1 &
SWAY_PID=$!

sleep 5

if ! ps -p $SWAY_PID > /dev/null; then
  echo "ERROR: Sway failed to start"
  echo "=== Sway Log ==="
  cat /tmp/sway.log
  exit 1
fi

echo "Searching for Wayland socket..."
WAYLAND_SOCKET=$(ls -1 $XDG_RUNTIME_DIR/wayland-* 2>/dev/null | grep -v '.lock$' | head -n1)

if [[ -z "$WAYLAND_SOCKET" ]]; then
  echo "ERROR: No Wayland socket found in $XDG_RUNTIME_DIR"
  echo "Available files:"
  ls -la $XDG_RUNTIME_DIR/
  echo "=== Sway Log ==="
  cat /tmp/sway.log
  exit 1
fi

export WAYLAND_DISPLAY=$(basename "$WAYLAND_SOCKET")
echo "✓ Found Wayland socket: $WAYLAND_DISPLAY"

if [ ! -S "$WAYLAND_SOCKET" ]; then
  echo "ERROR: $WAYLAND_SOCKET is not a valid socket"
  echo "Available sockets:"
  ls -la $XDG_RUNTIME_DIR/
  exit 1
fi

echo "✓ Sway started successfully with display: $WAYLAND_DISPLAY"

sleep 3

if pgrep -x "obs" > /dev/null; then
  echo "✓ OBS started successfully via Sway"
else
  echo "WARNING: OBS not running, starting manually..."
  obs --platform wayland > /tmp/obs.log 2>&1 &
  sleep 2
fi

echo "Configuring wayvnc..."
mkdir -p $HOME/.config/wayvnc
cat > $HOME/.config/wayvnc/config << EOF
address=0.0.0.0
enable_auth=false
#username=obsuser
#password=$VNC_PASS
EOF
chmod 600 $HOME/.config/wayvnc/config

echo "Starting wayvnc..."
wayvnc -C $HOME/.config/wayvnc/config 0.0.0.0 5900 > /tmp/wayvnc.log 2>&1 &
WAYVNC_PID=$!

sleep 3

if ! ps -p $WAYVNC_PID > /dev/null; then
  echo "ERROR: wayvnc failed to start"
  echo "=== wayvnc Log ==="
  cat /tmp/wayvnc.log
  echo "=== Available Wayland outputs ==="
  wayvnc --list-outputs 2>&1 || true
  exit 1
fi

echo "✓ wayvnc started successfully on port 5900"

if command -v /usr/share/novnc/utils/novnc_proxy >/dev/null 2>&1; then
  echo "Starting noVNC..."
  /usr/share/novnc/utils/novnc_proxy --vnc localhost:5900 --listen 6080 > /tmp/novnc.log 2>&1 &
  sleep 2
  echo "✓ noVNC started on port 6080"
fi

echo ""
echo "=========================================="
echo "✓ Setup complete!"
echo "=========================================="
echo "VNC Access:    localhost:5900"
echo "Web Access:    http://localhost:6080"
echo "Username:      obsuser"
echo "Password:      [hidden]"
echo "Wayland Display: $WAYLAND_DISPLAY"
echo "=========================================="
echo ""
echo "Monitoring logs..."

tail -f /tmp/*.log &

wait
