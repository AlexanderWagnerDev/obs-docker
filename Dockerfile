FROM alexanderwagnerdev/ubuntu:autoupdate

ARG VNC_PASS
ENV VNC_PASS=${VNC_PASS}
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y \
    software-properties-common wget curl git gnupg \
    wayfire wayvnc xwayland \
    lxqt-core lxqt-session lxqt-panel lxqt-runner lxqt-config \
    pcmanfm-qt qterminal \
    websockify novnc \
    ffmpeg firefox python3-pip vlc vlc-l10n v4l2loopback-dkms \
    gstreamer1.0-plugins-base gstreamer1.0-plugins-good gstreamer1.0-plugins-bad \
    gstreamer1.0-plugins-ugly gstreamer1.0-libav gstreamer1.0-tools \
    gstreamer1.0-alsa gstreamer1.0-gl gstreamer1.0-pulseaudio \
    mesa-utils libgl1-mesa-dri \
    fonts-dejavu fonts-noto fonts-freefont-ttf fonts-liberation \
    dbus-x11 \
    qtwayland5 libqt5waylandclient5 \
    wlroots \
    sudo \
    && \
    add-apt-repository ppa:obsproject/obs-studio -y && \
    apt-get update && \
    apt-get install -y obs-studio && \
    rm -rf /var/lib/apt/lists/*

RUN useradd -m -s /bin/bash -u 1500 obsuser && \
    echo "obsuser ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers && \
    mkdir -p /home/obsuser/.config/obs-studio && \
    chown -R obsuser:obsuser /home/obsuser

RUN mkdir -p /home/obsuser/.config/wayfire && \
    cat > /home/obsuser/.config/wayfire.ini << 'EOF'
[core]
plugins = autostart decoration vswitch window-rules

[autostart]
panel = lxqt-panel
obs = obs --platform wayland

[output:HEADLESS-1]
mode = 1920x1080@60
position = 0,0
transform = normal
EOF

RUN chown -R obsuser:obsuser /home/obsuser/.config

RUN mkdir -p /home/obsuser/.config/autostart && \
    cat > /home/obsuser/.config/autostart/obs.desktop << 'EOF'
[Desktop Entry]
Type=Application
Name=OBS Studio
Exec=obs --platform wayland
X-LXQt-Need-Tray=false
EOF

RUN chown -R obsuser:obsuser /home/obsuser/.config/autostart

COPY start.sh /start.sh
RUN chmod +x /start.sh

USER obsuser
WORKDIR /home/obsuser

EXPOSE 5900 6080
HEALTHCHECK CMD curl --fail http://localhost:6080/ || exit 1

CMD ["/start.sh"]
