#!/bin/bash
set -e

if [[ -n "$TZ" ]]; then
  echo "Setting timezone to $TZ..."
  sudo ln -snf /usr/share/zoneinfo/$TZ /etc/localtime
  echo $TZ | sudo tee /etc/timezone > /dev/null
fi

if [[ -n "$LOCALE" ]]; then
  export LANG=$LOCALE
  export LANGUAGE=${LOCALE%%_*}:${LOCALE%%.*}
  export LC_ALL=$LOCALE
  sudo update-locale LANG=$LOCALE
fi

# --- GPU detection -----------------------------------------------------------
# The driver comes from the host; here we only pick the matching VA-API backend.
detect_gpu_vendor() {
  if [[ -e /dev/nvidiactl || -e /dev/nvidia0 ]]; then
    echo "nvidia"
    return
  fi
  local vendor_file
  for vendor_file in /sys/class/drm/card*/device/vendor; do
    [[ -r "$vendor_file" ]] || continue
    case "$(cat "$vendor_file" 2>/dev/null)" in
      0x1002) echo "amd";   return ;;
      0x8086) echo "intel"; return ;;
    esac
  done
  echo "none"
}

GPU_VENDOR=${GPU_VENDOR:-$(detect_gpu_vendor)}
export GPU_VENDOR

if [[ -z "$LIBVA_DRIVER_NAME" ]]; then
  case "$GPU_VENDOR" in
    amd)    export LIBVA_DRIVER_NAME=radeonsi ;;
    intel)  export LIBVA_DRIVER_NAME=iHD ;;
    nvidia) export LIBVA_DRIVER_NAME=nvidia ;;
  esac
fi

# Older Intel GPUs (Gen7 and below) need i965 instead of iHD.
if [[ "$GPU_VENDOR" == "intel" && "$LIBVA_DRIVER_NAME" == "iHD" ]] && command -v vainfo >/dev/null 2>&1; then
  if ! vainfo --display drm >/dev/null 2>&1; then
    export LIBVA_DRIVER_NAME=i965
  fi
fi

echo "=========================================="
echo "Starting OBS Container by AlexanderWagnerDev"
echo "User: $(whoami) (UID: $(id -u))"
echo "Locale: $LANG"
echo "Timezone: $TZ"
echo "Keyboard: $KEYBOARD_LAYOUT"
echo "GPU: ${GPU_VENDOR}${LIBVA_DRIVER_NAME:+ (VA-API: $LIBVA_DRIVER_NAME)}"
echo "=========================================="

export XDG_RUNTIME_DIR=/tmp/runtime-$(id -u)
mkdir -p $XDG_RUNTIME_DIR
chmod 700 $XDG_RUNTIME_DIR

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

KB_LAYOUT=${KEYBOARD_LAYOUT:-us}

echo "Setting keyboard layout to $KB_LAYOUT..."
setxkbmap $KB_LAYOUT 2>/dev/null || setxkbmap us 2>/dev/null || echo "WARNING: Could not set keyboard layout"

echo "Starting D-Bus session..."
eval $(dbus-launch --sh-syntax)
export DBUS_SESSION_BUS_ADDRESS
export DBUS_SESSION_BUS_PID

echo "Starting PulseAudio..."
pulseaudio --start --exit-idle-time=-1 > /tmp/pulseaudio.log 2>&1 &
sleep 2

if pgrep -u $(id -u) pulseaudio > /dev/null; then
  echo "✓ PulseAudio started"
else
  echo "WARNING: PulseAudio may not be running"
fi

echo "Starting Openbox window manager..."
openbox > /tmp/openbox.log 2>&1 &
OPENBOX_PID=$!

sleep 2

if ! ps -p $OPENBOX_PID > /dev/null; then
  echo "WARNING: Openbox may have backgrounded"
fi

echo "✓ Openbox started"

echo "Starting LXQt..."
startlxqt > /tmp/lxqt.log 2>&1 &
LXQT_PID=$!

sleep 5

if ! ps -p $LXQT_PID > /dev/null; then
  echo "WARNING: LXQt may have backgrounded, checking processes..."
fi

echo "✓ LXQt session started"

sleep 3

echo "Starting x11vnc with password protection..."
x11vnc -display $DISPLAY -forever -shared -rfbport 5900 -passwd "$VNC_PASS" -xkb > /tmp/x11vnc.log 2>&1 &
X11VNC_PID=$!

sleep 3

if ! ps -p $X11VNC_PID > /dev/null; then
  echo "ERROR: x11vnc failed to start"
  cat /tmp/x11vnc.log
  exit 1
fi

if ss -tuln | grep -q ':5900'; then
  echo "✓ x11vnc started successfully on port 5900 (password protected)"
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
echo "OBS Docker by AlexanderWagnerDev"
echo "VNC Access:    localhost:5900"
echo "VNC Password:  *** (set via VNC_PASS)"
echo "Web Access:    http://localhost:6080"
echo "Desktop:       LXQt on X11 (via Xvfb)"
echo "Display:       $DISPLAY"
echo "Resolution:    $RESOLUTION"
echo "Locale:        $LANG"
echo "Timezone:      $TZ"
echo "Keyboard:      $KEYBOARD_LAYOUT"
echo "GPU:           ${GPU_VENDOR}${LIBVA_DRIVER_NAME:+ (VA-API: $LIBVA_DRIVER_NAME)}"
echo "=========================================="
echo ""

wait
