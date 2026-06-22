FROM alexanderwagnerdev/ubuntu:26.04

ARG VNC_PASS=OBS1234!
ARG LOCALE=en_US.UTF-8
ARG TZ=UTC
ARG KEYBOARD_LAYOUT=us

ENV VNC_PASS=${VNC_PASS}
ENV LOCALE=${LOCALE}
ENV TZ=${TZ}
ENV LANG=${LOCALE}
ENV KEYBOARD_LAYOUT=${KEYBOARD_LAYOUT}
ENV LANGUAGE=${LOCALE%%_*}:${LOCALE%%.*}
ENV LC_ALL=${LOCALE}
ENV DEBIAN_FRONTEND=noninteractive

# Ubuntu 26.04: lxqt-branding-debian conflicts with lxqt-panel over /etc/xdg/lxqt/panel.conf
RUN apt-get update && \
    apt-get purge -y lxqt-branding-debian 2>/dev/null || true && \
    rm -rf /var/lib/apt/lists/*

# Generate locales before package installs to avoid perl/locale warnings
RUN apt-get update && \
    apt-get install -y locales && \
    sed -i '/^#.*/s/^# //' /etc/locale.gen && \
    locale-gen && \
    update-locale LANG=${LOCALE} && \
    rm -rf /var/lib/apt/lists/*

# --no-install-recommends avoids pulling lxqt-branding-debian back in
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y --no-install-recommends \
    software-properties-common wget curl git gnupg ca-certificates \
    xwayland x11vnc xvfb x11-xkb-utils \
    lxqt-core \
    pcmanfm-qt qterminal \
    websockify novnc \
    ffmpeg firefox chromium python3-pip vlc vlc-l10n v4l2loopback-dkms \
    gstreamer1.0-plugins-base gstreamer1.0-plugins-good gstreamer1.0-plugins-bad \
    gstreamer1.0-plugins-ugly gstreamer1.0-libav gstreamer1.0-tools \
    gstreamer1.0-alsa gstreamer1.0-gl gstreamer1.0-pulseaudio \
    mesa-utils libgl1-mesa-dri \
    fonts-dejavu fonts-noto fonts-freefont-ttf fonts-liberation fonts-roboto fonts-ubuntu fontconfig \
    dbus-x11 \
    openbox \
    pulseaudio pulseaudio-utils pavucontrol \
    obs-studio \
    iproute2 \
    nano vim htop net-tools iputils-ping \
    sudo \
    cron \
    && rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/* /tmp/* /var/tmp/*

RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN useradd -m -s /bin/bash -u 1500 obsuser && \
    echo "obsuser ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers && \
    mkdir -p /home/obsuser/.config/obs-studio && \
    chown -R obsuser:obsuser /home/obsuser

RUN mkdir -p /home/obsuser/.local/share/applications

RUN cat > /home/obsuser/.local/share/applications/firefox.desktop << 'EOF'
[Desktop Entry]
Name=Firefox Web Browser
Comment=Browse the World Wide Web
Exec=firefox %u
Icon=firefox
Terminal=false
Type=Application
Categories=Network;WebBrowser;
MimeType=text/html;text/xml;application/xhtml+xml;
EOF

RUN cat > /home/obsuser/.local/share/applications/chromium.desktop << 'EOF'
[Desktop Entry]
Name=Chromium Web Browser
Comment=Access the Internet
Exec=chromium %U
Icon=chromium
Terminal=false
Type=Application
Categories=Network;WebBrowser;
MimeType=text/html;text/xml;application/xhtml+xml;x-scheme-handler/http;x-scheme-handler/https;
EOF

RUN cat > /home/obsuser/.local/share/applications/vlc.desktop << 'EOF'
[Desktop Entry]
Name=VLC Media Player
Comment=Read, capture, broadcast your multimedia streams
Exec=vlc %U
Icon=vlc
Terminal=false
Type=Application
Categories=AudioVideo;Player;Recorder;
MimeType=video/mpeg;video/x-mpeg;video/x-msvideo;video/quicktime;video/x-ms-asf;video/x-ms-wmv;video/x-matroska;audio/mpeg;audio/x-wav;audio/x-mpegurl;audio/x-scpls;
EOF

RUN cat > /home/obsuser/.local/share/applications/pavucontrol.desktop << 'EOF'
[Desktop Entry]
Name=PulseAudio Volume Control
Comment=Adjust the volume level
Exec=pavucontrol
Icon=multimedia-volume-control
Terminal=false
Type=Application
Categories=AudioVideo;Audio;Mixer;GTK;
EOF

RUN mkdir -p /home/obsuser/.config/autostart && \
    cat > /home/obsuser/.config/autostart/obs.desktop << 'EOF'
[Desktop Entry]
Type=Application
Name=OBS Studio
Exec=obs
X-LXQt-Need-Tray=false
EOF

RUN mkdir -p /home/obsuser/.config/openbox && \
    cat > /home/obsuser/.config/openbox/menu.xml << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<openbox_menu xmlns="http://openbox.org/3.4/menu">
  <menu id="root-menu" label="Openbox 3">
    <item label="Terminal">
      <action name="Execute">
        <command>qterminal</command>
      </action>
    </item>
    <item label="Firefox">
      <action name="Execute">
        <command>firefox</command>
      </action>
    </item>
    <item label="Chromium">
      <action name="Execute">
        <command>chromium</command>
      </action>
    </item>
    <item label="File Manager">
      <action name="Execute">
        <command>pcmanfm-qt</command>
      </action>
    </item>
    <item label="VLC">
      <action name="Execute">
        <command>vlc</command>
      </action>
    </item>
    <item label="Audio Mixer">
      <action name="Execute">
        <command>pavucontrol</command>
      </action>
    </item>
    <separator />
    <item label="Exit">
      <action name="Exit" />
    </item>
  </menu>
</openbox_menu>
EOF

RUN chown -R obsuser:obsuser /home/obsuser/.config /home/obsuser/.local

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

USER obsuser
WORKDIR /home/obsuser

EXPOSE 5900 6080
HEALTHCHECK CMD curl --fail http://localhost:6080/ || exit 1

CMD ["/entrypoint.sh"]
