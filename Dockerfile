FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive
ENV VNC_PASS=123456

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y software-properties-common wget curl git gnupg lxde x11vnc xvfb novnc websockify python3-pip v4l2loopback-dkms ffmpeg libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev libgstreamer-plugins-bad1.0-dev gstreamer1.0-plugins-base gstreamer1.0-plugins-good gstreamer1.0-plugins-bad gstreamer1.0-plugins-ugly gstreamer1.0-libav gstreamer1.0-tools gstreamer1.0-x gstreamer1.0-alsa gstreamer1.0-gl gstreamer1.0-gtk3 gstreamer1.0-qt5 gstreamer1.0-pulseaudio && \
    add-apt-repository ppa:obsproject/obs-studio -y && \
    apt-get update && \
    apt-get install -y obs-studio && \
    rm -rf /var/lib/apt/lists/*

RUN useradd -m obsuser && \
    chown -R obsuser:obsuser /home/obsuser && \
    usermod -aG sudo obsuser

USER obsuser
ENV HOME=/home/obsuser

COPY start.sh /start.sh
RUN sudo chmod +x /start.sh

EXPOSE 5900 6080

CMD ["/start.sh"]
