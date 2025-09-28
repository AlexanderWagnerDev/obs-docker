FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y \
      software-properties-common \
      wget \
      curl \
      git \
      gnupg \
      lxde \
      x11vnc \
      xvfb \
      novnc \
      websockify \
      python3-pip && \
    add-apt-repository ppa:obsproject/obs-studio -y && \
    apt-get update && \
    apt-get install -y obs-studio && \
    rm -rf /var/lib/apt/lists/*

RUN mkdir -p /root/.vnc
RUN x11vnc -storepasswd 123456 /root/.vnc/passwd

COPY start.sh /start.sh
RUN chmod +x /start.sh

EXPOSE 5900 6080

CMD ["/start.sh"]
