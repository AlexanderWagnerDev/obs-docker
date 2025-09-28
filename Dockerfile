FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive
ENV VNC_PASS=123456

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y software-properties-common wget curl git gnupg lxde x11vnc xvfb novnc websockify python3-pip v4l2loopback-dkms && \
    add-apt-repository ppa:obsproject/obs-studio -y && \
    apt-get update && \
    apt-get install -y obs-studio && \
    rm -rf /var/lib/apt/lists/*

RUN useradd -m obsuser && \
    chown -R obsuser:obsuser /home/obsuser

USER obsuser
ENV HOME=/home/obsuser

COPY start.sh /start.sh
RUN chmod +x /start.sh

EXPOSE 5900 6080

CMD ["/start.sh"]
