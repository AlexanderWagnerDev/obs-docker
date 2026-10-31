# 🎥 OBS Docker — Legacy

> 🧊 **Frozen branch.** This image is based on **Ubuntu 24.04** and only receives security-relevant fixes. It is kept for existing deployments — new setups should use [`main`](https://github.com/AlexanderWagnerDev/obs-docker/tree/main).

**OBS Studio in a complete LXQt desktop — remotely accessible via VNC or noVNC in your browser.**

Perfect for headless servers, cloud streaming and remote recording setups.

[![Docker Hub Pulls](https://img.shields.io/docker/pulls/alexanderwagnerdev/obs?style=flat-square&logo=docker)](https://hub.docker.com/r/alexanderwagnerdev/obs)
[![Image Size](https://img.shields.io/docker/image-size/alexanderwagnerdev/obs/legacy?style=flat-square&label=image%20size)](https://hub.docker.com/r/alexanderwagnerdev/obs)
[![GHCR](https://img.shields.io/badge/ghcr.io-alexanderwagnerdev%2Fobs-2496ED?style=flat-square&logo=github)](https://github.com/AlexanderWagnerDev/obs-docker/pkgs/container/obs)
[![License](https://img.shields.io/github/license/AlexanderWagnerDev/obs-docker?style=flat-square)](https://github.com/AlexanderWagnerDev/obs-docker/blob/main/LICENSE)
[![Platform](https://img.shields.io/badge/platform-linux%2Famd64-lightgrey?style=flat-square)](https://github.com/AlexanderWagnerDev/obs-docker)

---

## 📑 Branches & Tags

| Branch | Image tag | Base | Status |
|--------|-----------|------|--------|
| `main` | `latest` | Ubuntu 26.04 | ✅ Stable |
| `beta` | `beta` | Ubuntu 26.04 | 🧪 Testing — may break |
| **`legacy`** | `legacy` | Ubuntu 24.04 | 🧊 Frozen — no new features |

Every branch is published to **both** registries with the same tag:

```bash
docker pull alexanderwagnerdev/obs:legacy        # Docker Hub
docker pull ghcr.io/alexanderwagnerdev/obs:legacy # GitHub Container Registry
```

---

## 🚀 Quick Start

### Docker Compose

```bash
git clone -b legacy https://github.com/AlexanderWagnerDev/obs-docker.git
cd obs-docker
cp .env.example .env
docker compose up -d
```

Then open **http://your-server-ip:6080** in your browser.

### Docker CLI

```bash
docker run -d \
  --name obs-docker \
  --restart unless-stopped \
  -e VNC_PASS='OBS1234!' \
  -e TZ=Europe/Vienna \
  -e LOCALE=de_AT.UTF-8 \
  -e KEYBOARD_LAYOUT=de \
  -p 5900:5900 \
  -p 6080:6080 \
  --shm-size=8g \
  alexanderwagnerdev/obs:legacy
```

> **Tip:** `--shm-size=8g` is recommended for stable browser and video performance.

---

## ⚙️ Configuration

All settings are configured through environment variables:

| Variable | Default | Description |
|----------|---------|-------------|
| `VNC_PASS` | `OBS1234!` | Password for VNC / noVNC access |
| `LOCALE` | `en_US.UTF-8` | System locale (e.g. `de_AT.UTF-8`) |
| `TZ` | `UTC` | Timezone (e.g. `Europe/Vienna`) |
| `KEYBOARD_LAYOUT` | `us` | Keyboard layout (e.g. `de`, `us`) |

Copy `.env.example` to `.env` and adjust the values for Docker Compose.

---

## 🔌 Ports

| Port | Protocol | Description |
|------|----------|-------------|
| `5900` | TCP | VNC — connect with a native VNC client |
| `6080` | TCP | noVNC — access from any web browser |

---

## 🖥️ Access

| Method | Address | Description |
|--------|---------|-------------|
| Browser | `http://your-ip:6080` | noVNC, no client install required |
| VNC client | `your-ip:5900` | RealVNC, TigerVNC, Remmina, … |

> OBS Studio starts automatically when the container boots.

---

## 📦 Included Software

- **OBS Studio** — latest release from the official OBS PPA
- **LXQt desktop** — lightweight desktop environment (`lxqt-core` metapackage)
- **Firefox & Chromium** — web browsers (handy for browser sources)
- **VLC** — media playback and capture
- **FFmpeg** — video/audio processing
- **GStreamer** — full plugin set
- **PulseAudio + PavuControl** — audio routing and mixing
- **v4l2loopback** — virtual camera support
- **noVNC / x11vnc / Xvfb** — remote desktop stack

---

## 📝 Good to Know

- Images are built for **`linux/amd64`** only.
- The container is designed to run **headless**; no GPU is required.
- A `HEALTHCHECK` verifies that noVNC is reachable on port `6080`.
- Container data is **not persisted** by default — add your own volume if needed.
- This branch stays on **Ubuntu 24.04** and receives no new features. Migrate to `main` when possible.

---

## 🔗 Links

- **Docker Hub:** [alexanderwagnerdev/obs](https://hub.docker.com/r/alexanderwagnerdev/obs)
- **GHCR:** [ghcr.io/alexanderwagnerdev/obs](https://github.com/AlexanderWagnerDev/obs-docker/pkgs/container/obs)
- **Base image:** [AlexanderWagnerDev/ubuntu-docker](https://github.com/AlexanderWagnerDev/ubuntu-docker)
- **Issues:** [GitHub Issues](https://github.com/AlexanderWagnerDev/obs-docker/issues)

## 📄 License

See the [LICENSE](LICENSE) file for details.

