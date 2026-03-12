# 🎥 OBS Docker

## WIP - only in testing!

[![Docker Hub](https://img.shields.io/docker/pulls/alexanderwagnerdev/obs?style=flat-square)](https://hub.docker.com/r/alexanderwagnerdev/obs)
[![GitHub](https://img.shields.io/github/license/AlexanderWagnerDev/obs-docker?style=flat-square)](https://github.com/AlexanderWagnerDev/obs-docker)

A Docker container running **OBS Studio** inside a full desktop environment (LXQt), accessible via VNC or noVNC in the browser — perfect for headless servers, cloud streaming, and remote recording setups.

---

## 🚀 Quick Start

### Using Docker Compose

1. Clone the repository:
   ```bash
   git clone https://github.com/AlexanderWagnerDev/obs-docker.git
   cd obs-docker
   ```

2. Copy and configure the environment file:
   ```bash
   cp .env.example .env
   ```

3. Start the container:
   ```bash
   docker compose up -d
   ```

4. Open OBS Studio in your browser at:
   ```
   http://your-server-ip:6080
   ```

### Using Docker CLI

```bash
docker run -d \
  --name obs-docker \
  --restart unless-stopped \
  -e VNC_PASS=OBS1234! \
  -e TZ=Europe/Vienna \
  -e LOCALE=de_AT.UTF-8 \
  -e KEYBOARD_LAYOUT=de \
  -p 5900:5900 \
  -p 6080:6080 \
  --shm-size=8g \
  alexanderwagnerdev/obs:latest
```

---

## ⚙️ Configuration

All settings are configured via environment variables:

| Variable | Default | Description |
|----------|---------|-------------|
| `VNC_PASS` | `OBS1234!` | VNC password for remote access |
| `LOCALE` | `en_US.UTF-8` | System locale |
| `TZ` | `UTC` | Timezone (e.g. `Europe/Vienna`) |
| `KEYBOARD_LAYOUT` | `us` | Keyboard layout (e.g. `de`, `us`) |

---

## 🔌 Port Configuration

| Port | Protocol | Description |
|------|----------|-------------|
| 5900 | TCP | VNC (direct client access) |
| 6080 | TCP | noVNC (browser-based access) |

---

## 📦 Included Software

The container ships with the following applications pre-installed:

- **OBS Studio** Latest Version — Screen recording & live streaming
- **LXQt Desktop** — Lightweight desktop environment
- **Firefox & Chromium** — Web browsers (useful for browser sources)
- **VLC Media Player** — Media playback
- **PulseAudio** — Audio management with PavuControl
- **GStreamer** — Multimedia pipeline framework
- **FFmpeg** — Video/audio processing
- **noVNC / x11vnc** — Remote desktop access

---

## 🖥️ Access

| Method | URL / Address | Description |
|--------|--------------|-------------|
| Browser (noVNC) | `http://your-ip:6080` | Access via any web browser |
| VNC Client | `your-ip:5900` | Connect with a VNC client (e.g. RealVNC, TigerVNC) |

> **Note:** OBS Studio starts automatically on container boot via the autostart configuration.

---

## 🔗 Links

- **Docker Hub:** [alexanderwagnerdev/obs-docker](https://hub.docker.com/r/alexanderwagnerdev/obs)
- **Base Image:** [alexanderwagnerdev/ubuntu-docker](https://github.com/AlexanderWagnerDev/ubuntu-docker)

## 📄 License

See LICENSE file for details.

---

# 🎥 OBS Docker (Deutsch)

Ein Docker-Container, der **OBS Studio** in einer vollständigen Desktop-Umgebung (LXQt) ausführt, zugänglich über VNC oder noVNC im Browser — ideal für Headless-Server, Cloud-Streaming und Remote-Recording-Setups.

---

## 🚀 Schnellstart

### Mit Docker Compose

1. Repository klonen:
   ```bash
   git clone https://github.com/AlexanderWagnerDev/obs-docker.git
   cd obs-docker
   ```

2. Umgebungsdatei kopieren und anpassen:
   ```bash
   cp .env.example .env
   ```

3. Container starten:
   ```bash
   docker compose up -d
   ```

4. OBS Studio im Browser öffnen:
   ```
   http://deine-server-ip:6080
   ```

### Mit Docker CLI

```bash
docker run -d \
  --name obs-docker \
  --restart unless-stopped \
  -e VNC_PASS=OBS1234! \
  -e TZ=Europe/Vienna \
  -e LOCALE=de_AT.UTF-8 \
  -e KEYBOARD_LAYOUT=de \
  -p 5900:5900 \
  -p 6080:6080 \
  --shm-size=8g \
  alexanderwagnerdev/obs:latest
```

---

## ⚙️ Konfiguration

Alle Einstellungen werden über Umgebungsvariablen konfiguriert:

| Variable | Standard | Beschreibung |
|----------|----------|-------------|
| `VNC_PASS` | `OBS1234!` | VNC-Passwort für den Fernzugriff |
| `LOCALE` | `en_US.UTF-8` | System-Locale |
| `TZ` | `UTC` | Zeitzone (z. B. `Europe/Vienna`) |
| `KEYBOARD_LAYOUT` | `us` | Tastaturlayout (z. B. `de`, `us`) |

---

## 🔌 Port-Konfiguration

| Port | Protokoll | Beschreibung |
|------|-----------|-------------|
| 5900 | TCP | VNC (direkter Client-Zugriff) |
| 6080 | TCP | noVNC (browserbasierter Zugriff) |

---

## 📦 Enthaltene Software

Der Container enthält folgende vorinstallierte Anwendungen:

- **OBS Studio** Letzte Version — Bildschirmaufnahme & Live-Streaming
- **LXQt Desktop** — Leichtgewichtige Desktop-Umgebung
- **Firefox & Chromium** — Webbrowser (nützlich für Browser-Quellen)
- **VLC Media Player** — Medienwiedergabe
- **PulseAudio** — Audioverwaltung mit PavuControl
- **GStreamer** — Multimedia-Pipeline-Framework
- **FFmpeg** — Video-/Audioverarbeitung
- **noVNC / x11vnc** — Remote-Desktop-Zugriff

---

## 🖥️ Zugriff

| Methode | URL / Adresse | Beschreibung |
|---------|--------------|-------------|
| Browser (noVNC) | `http://deine-ip:6080` | Zugriff über jeden Webbrowser |
| VNC-Client | `deine-ip:5900` | Verbindung mit einem VNC-Client (z. B. RealVNC, TigerVNC) |

> **Hinweis:** OBS Studio startet beim Container-Boot automatisch über die Autostart-Konfiguration.

---

## 🔗 Links

- **Docker Hub:** [alexanderwagnerdev/obs-docker](https://hub.docker.com/r/alexanderwagnerdev/obs)
- **Basis-Image:** [alexanderwagnerdev/ubuntu-docker](https://github.com/AlexanderWagnerDev/ubuntu-docker)

## 📄 Lizenz

Details siehe LICENSE-Datei.
