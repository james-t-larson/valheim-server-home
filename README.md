# 🛡️ Valheim Dedicated Server

Welcome! This repository contains everything you need to run your very own private, dedicated **Valheim** server using Docker.

Whether you want a persistent world for you and your friends so anyone can play even when you're offline, or you just want full control over your world saves and backups, this project makes it easy to set up and manage—no server administration experience required!

---

## 🏗️ Under the Hood: Powered by `valheim-server-docker`

This project is built directly on top of [**community-valheim-tools/valheim-server-docker**](https://github.com/community-valheim-tools/valheim-server-docker), a popular, production-ready, open-source Docker container image (`ghcr.io/community-valheim-tools/valheim-server`) maintained by the Valheim community.

### What is `valheim-server-docker`?

[**`valheim-server-docker`**](https://github.com/community-valheim-tools/valheim-server-docker) is an all-in-one container solution designed specifically for hosting dedicated Valheim game servers. Instead of requiring you to manually install SteamCMD, configure Linux runtime dependencies, manage cron jobs, or worry about corrupted world saves when stopping the server, it packages everything into a standardized, automated environment:

* 🔄 **Automatic Game Updates**: Downloads the official Valheim dedicated server files directly via SteamCMD on startup and checks for updates automatically.
* 💾 **Automated World Backups**: Features an integrated backup utility that periodically compresses and archives your world saves into timestamped `.zip` files in your mounted `config/backups` directory without interrupting gameplay.
* 🌐 **Crossplay Ready**: Built-in support for crossplay (`CROSSPLAY=true`), enabling seamless multiplayer between Steam, Xbox, and PC Game Pass players.
* 🧩 **Modding Support**: First-class support for mod frameworks, including [BepInExPack Valheim](https://github.com/community-valheim-tools/valheim-server-docker#bepinexpack-valheim) and [ValheimPlus](https://github.com/community-valheim-tools/valheim-server-docker#valheimplus).
* 🪝 **Event Hooks & Discord Webhooks**: Built-in triggers for custom scripts and Discord notifications on server lifecycle events (startup, shutdown, player joins/leaves, game updates, and backup creation).
* 🛡️ **Process Supervision & Graceful Shutdowns**: An internal supervisor monitors server health and ensures clean shutdowns so world state is always saved properly before the container exits.

### How This Repository Fits In

While the upstream [`valheim-server-docker`](https://github.com/community-valheim-tools/valheim-server-docker) image provides the core game server engine, **this repository provides a turnkey, beginner-friendly local orchestration layer**:

1. **Interactive Setup Script (`./start.sh`)**: Prompts you for basic settings (server name, world name, password, crossplay, port) and auto-generates your `.env` configuration file.
2. **Pre-configured `docker-compose.yml`**: Configured with persistent volumes (`config/` and `data/`), proper permissions (`CAP_SYS_NICE`), and platform emulation for Apple Silicon Macs (`linux/amd64`).
3. **Live Web Log Viewer**: Bundles [Dozzle](https://dozzle.dev) on port 8080 out of the box so you can view live console logs and monitor container CPU/RAM directly in your web browser.
4. **Comprehensive Documentation**: Plain-English guides for first-time Docker users, networking, backups, and troubleshooting.

For advanced configurations, environment variables, or custom hook scripts, check out the [upstream repository on GitHub](https://github.com/community-valheim-tools/valheim-server-docker).

---

## ⚡ Quick Start (Up in 60 Seconds)

1. **Ensure Docker Desktop is running** on your computer.
2. **Open Terminal** in this folder and run the interactive setup script:
   ```bash
   ./start.sh
   ```
3. Follow the friendly prompts (or press `Enter` to keep the default settings).
4. The server will launch in the background. Check its status with:
   ```bash
   docker compose ps
   ```

### Daily Commands Cheat Sheet
| Task | Command |
| :--- | :--- |
| **Start Server & Web Viewer** | `docker compose up -d` (or `./start.sh`) |
| **Check Status** | `docker compose ps` |
| **Web Log Viewer (Dozzle)** | `http://localhost:8080` |
| **CLI Live Logs** | `docker compose logs -f` |
| **Stop Server & Tools** | `docker compose down` |
| **Update Server & Game** | `docker compose pull && docker compose up -d` |

---

## 📚 Documentation Guides

To keep things organized and easy to navigate, detailed instructions have been broken down into dedicated guides:

| Guide | Description |
| :--- | :--- |
| 🚀 **[Quick Start & Operations Guide](docs/getting-started.md)** | Step-by-step startup, interactive setup, stopping, updates, and using the Docker Desktop GUI. |
| 💡 **[Docker Explained in Plain English](docs/docker-explained.md)** | What Docker is, images vs. containers vs. volumes, and Apple Silicon Mac emulation. |
| 🔍 **[Server Configuration & `docker-compose.yml`](docs/configuration.md)** | Line-by-line breakdown of configuration settings, ports, and environment variables. |
| 🎮 **[How to Connect to Your Server](docs/connecting.md)** | Connecting locally (`localhost`), on home Wi-Fi (LAN), over the Internet, and Crossplay. |
| 📊 **[Log Monitoring with Dozzle](docs/dozzle.md)** | Real-time web-based Docker log viewing and container statistics via [dozzle.dev](https://dozzle.dev). |
| 💾 **[World Backups & Restoration](docs/backups.md)** | Automatic backup folder, manual snapshots, save locations, and restoring old saves. |
| ❓ **[Troubleshooting & Administrator Guide](docs/troubleshooting.md)** | Adding server admins (`adminlist.txt`), fixing common connection issues, and error diagnosis. |
| 🌐 **[Upstream Image Documentation](https://github.com/community-valheim-tools/valheim-server-docker)** | Official documentation for the underlying `valheim-server-docker` image (advanced settings, modding, webhooks). |

---

## 📊 Live Web Monitoring with Dozzle

Instead of watching logs solely in a terminal window, [Dozzle](https://dozzle.dev) is **built directly into [`docker-compose.yml`](docker-compose.yml)**! It is a lightweight (~7 MB), real-time, browser-based log viewer and container monitor.

### Starts Automatically
Dozzle spins up alongside your Valheim server automatically whenever you run `./start.sh` or `docker compose up -d`. Container actions (Start, Stop, Restart) are pre-enabled so you can manage your server right from your browser.

### Accessing Dozzle from a Local Machine

* **On the same machine running Docker**:
  Open your web browser and go to:
  ```text
  http://localhost:8080
  ```
  *(or `http://127.0.0.1:8080`)*

* **From another computer, tablet, or phone on your local network (LAN)**:
  1. Find your host computer's local network IP address:
     - **macOS**: Run `ipconfig getifaddr en0` in Terminal (or check **System Settings > Wi-Fi > Details**).
     - **Windows**: Run `ipconfig` in PowerShell and look for **IPv4 Address**.
     - **Linux**: Run `hostname -I`.
  2. Open any web browser on your second device and visit:
     ```text
     http://<HOST-LOCAL-IP>:8080
     ```
     *(Example: `http://192.168.1.45:8080`)*

From the Dozzle web dashboard, simply click **`valheim-server`** to watch live console activity, verify when the game server has connected (`Game server connected`), and monitor memory and CPU usage.

👉 For complete instructions and configuration options, see the **[Dozzle Monitoring Guide](docs/dozzle.md)**.

---

## 📁 Repository Structure

```text
valheim/
├── .env                  # Auto-generated environment variables (from start.sh)
├── docker-compose.yml    # Docker Compose server configuration
├── start.sh              # Interactive configuration and startup script
├── README.md             # Project overview and documentation index
├── config/               # Persistent server configuration, saves & backups (Docker volume)
│   ├── adminlist.txt     # Steam64 IDs of server admins
│   ├── backups/          # Automatic world save zip backups
│   └── worlds_local/     # Active world save files (.db and .fwl)
├── data/                 # Downloaded Valheim game server files (Docker volume)
└── docs/                 # Detailed documentation guides
    ├── getting-started.md
    ├── docker-explained.md
    ├── configuration.md
    ├── connecting.md
    ├── dozzle.md
    ├── backups.md
    └── troubleshooting.md
```

---

*Skål and happy exploring in the Tenth Realm!* 🪓⛵
