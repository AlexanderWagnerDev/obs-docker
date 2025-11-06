FROM alexanderwagnerdev/ubuntu:autoupdate

ENV VNC_PASS=${VNC_PASS}
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y \
    software-properties-common wget curl git gnupg \
    sway waybar wayvnc xwayland \
    websockify python3-pip novnc \
    v4l2loopback-dkms ffmpeg vlc vlc-l10n firefox \
    libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev libgstreamer-plugins-bad1.0-dev \
    gstreamer1.0-plugins-base gstreamer1.0-plugins-good gstreamer1.0-plugins-bad \
    gstreamer1.0-plugins-ugly gstreamer1.0-libav gstreamer1.0-tools \
    gstreamer1.0-alsa gstreamer1.0-gl gstreamer1.0-pulseaudio \
    mesa-utils libgl1-mesa-dri \
    sudo \
    && \
    add-apt-repository ppa:obsproject/obs-studio -y && \
    apt-get update && \
    apt-get install -y obs-studio && \
    rm -rf /var/lib/apt/lists/*

RUN useradd -m -s /bin/bash -u 1500 obsuser && \
    echo "obsuser ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers && \
    mkdir -p /home/obsuser/.config/sway && \
    chown -R obsuser:obsuser /home/obsuser

RUN cat > /home/obsuser/.config/sway/config << 'EOF'
xwayland enable

output * {
    mode 1920x1080
}

exec obs --platform wayland
exec firefox
EOF

RUN chown -R obsuser:obsuser /home/obsuser/.config/sway

RUN mkdir -p /home/obsuser/.config/obs-studio \
    && chown -R obsuser:obsuser /home/obsuser

COPY start.sh /start.sh
RUN chmod +x /start.sh

USER obsuser
WORKDIR /home/obsuser

EXPOSE 5900 6080

CMD ["/start.sh"]
