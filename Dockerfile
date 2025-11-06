FROM alexanderwagnerdev/ubuntu:autoupdate

ARG VNC_PASS
ENV VNC_PASS=${VNC_PASS}
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y \
    software-properties-common wget curl git gnupg \
    sway waybar wayvnc \
    websockify python3-pip novnc \
    v4l2loopback-dkms ffmpeg \
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
    echo "exec obs" > /home/obsuser/.config/sway/config && \
    echo "xwayland enable" >> /home/obsuser/.config/sway/config && \
    chown -R obsuser:obsuser /home/obsuser

COPY start.sh /start.sh
RUN chmod +x /start.sh

USER obsuser
WORKDIR /home/obsuser

EXPOSE 5900 6080
HEALTHCHECK CMD curl --fail http://localhost:6080/ || exit 1

CMD ["/start.sh"]
