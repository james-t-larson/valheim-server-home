# 🚀 Quick Start & Operations Guide

This guide walks you through launching, managing, updating, and shutting down your dedicated Valheim server using either the command line or the Docker Desktop application.

---

## 📋 Prerequisites

Before running the server, ensure you have:
1. **Docker Desktop installed and running**:
   - Download for Mac or Windows from [docker.com](https://www.docker.com/products/docker-desktop/).
   - Ensure the Docker daemon is active (look for the whale icon in your Mac menu bar or Windows system tray).
2. **Terminal (Mac/Linux) or PowerShell (Windows)**:
   - macOS: Press `Cmd + Space`, type `Terminal`, and press `Enter`.
   - Windows: Press `Windows Key`, type `PowerShell`, and press `Enter`.

---

## 🛠️ Step 1: Navigate to the Project Directory

Open your terminal and navigate to the project directory:
```bash
cd /path/to/valheim
```
*(Tip on Mac: Type `cd ` followed by a space, then drag the `valheim` folder from Finder into the Terminal window and hit Enter).*

---

## ⚙️ Step 2: Interactive Server Setup (`./start.sh`)

We provide an interactive configuration and startup script: [`start.sh`](../start.sh).

Run:
```bash
./start.sh
```

The script guides you through configuring all essential server parameters (press `Enter` to accept defaults in brackets):
* **Game Port**: Default `2456:2456/udp` (primary port players connect to).
* **Steam Query Port**: Default `2457:2457/udp` (Steam server browser query port).
* **Server Name**: Default `My Valheim Server` (name shown in public server lists).
* **World Name**: Default `Dedicated` (name of the world save file).
* **Server Password**: Default `secret1234` (must be at least 5 characters and cannot appear in the server name).
* **Public Visibility**: Default `true` (set `false` to hide from the community list).
* **Crossplay**: Default `false` (set `true` to enable Microsoft PlayFab crossplay for Xbox & PC Game Pass).
* **Steam Platform**: Default `linux64`.
* **Playit.gg Secret Key**: Default empty (leave blank to claim via web, or paste your account secret key).

### What `start.sh` does automatically:
1. Collects and validates your answers.
2. Writes persistent settings to `~/.bashrc`.
3. Creates a local [`.env`](../.env) file so Docker Compose works consistently.
4. Exports variables to your current shell.
5. Launches the Valheim server, Dozzle log viewer, and Playit tunnel agent concurrently (`docker compose up -d`).

> [!NOTE]  
> The very first time you launch the server, Docker downloads the image and Steam downloads the Valheim game server files (~1–2 GB total). This usually takes **2 to 4 minutes**. Wait until you see `Game server connected` in the logs before connecting.

---

## 🔍 Step 3: Checking Server Status

To check if the containers are running:
```bash
docker compose ps
```

Under the **STATUS** column, you should see `valheim-server`, `dozzle`, and `playit-agent` marked as `Up` (e.g. `Up 2 minutes`).

---

## 📜 Step 4: Viewing Server Logs & Playit Claim URL

You can view your server logs and claim your Playit.gg tunnel using either your web browser or terminal:

### Option A: Web Browser via Dozzle (Recommended)
Open your browser and navigate to:
```text
http://localhost:8080
```
Dozzle launches automatically alongside your server. It provides real-time log streaming, search, memory and CPU stats, and container controls.
* Click **`valheim-server`** to watch boot progress and player events.
* Click **`playit-agent`** to view your **Playit.gg claim URL** (e.g. `https://playit.gg/claim/...`) to set up zero-port-forwarding Internet play.

### Option B: Terminal CLI
To stream live logs in your terminal:
```bash
docker compose logs -f
```
Or to check just the Playit claim URL:
```bash
docker compose logs playit
```

* **To exit the log viewer**: Press `Ctrl + C`. This stops viewing logs; the server keeps running uninterrupted in the background.

👉 For complete instructions on connecting remote players without port forwarding, see the **[Playit.gg Tunnel Guide](playit.md)**.
👉 For advanced log viewer features, see the **[Dozzle Monitoring Guide](dozzle.md)**.

---

## 🛑 Step 5: Stopping the Server Safely

When shutting down or restarting your host computer:
```bash
docker compose down
```

> [!IMPORTANT]  
> Always use `docker compose down` (or the Stop button in Docker Desktop). This sends a graceful `SIGTERM` signal to Valheim, ensuring all world saves and player data are flushed to disk before shutting down.

---

## 🔄 Step 6: Updating the Server

When Iron Gate releases a new Valheim game patch:
```bash
docker compose pull
docker compose up -d
```
Docker pulls the latest image updates and restarts the container while preserving your world saves.

---

## 🖱️ Point-and-Click: Using Docker Desktop

If you prefer not using the command line:
1. Open the **Docker Desktop** application.
2. Click **Containers** in the left sidebar.
3. Locate the `valheim-server` container.
   - **Start**: Click the green **Play** button (▶️).
   - **Stop**: Click the square **Stop** button (⏹️).
   - **Logs**: Click the container name to view live console logs.
   - **Stats**: Click the **Stats** tab to see CPU and memory usage.

---

## 📚 Related Guides
- [Playit.gg Zero-Port-Forwarding Tunnel](playit.md)
- [Docker Explained in Plain English](docker-explained.md)
- [Server Configuration & `docker-compose.yml`](configuration.md)
- [How to Connect to Your Server](connecting.md)
- [Monitoring Logs with Dozzle](dozzle.md)
- [World Backups & Restoration](backups.md)
- [Troubleshooting & Admin Guide](troubleshooting.md)
