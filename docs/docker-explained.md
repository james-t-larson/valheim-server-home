# 💡 What is Docker? (In Plain English)

If you're new to Docker, this guide explains how it works, why it's the ideal way to host a Valheim dedicated server, and the core concepts you'll encounter.

---

## 🎮 The Old Way vs. The Docker Way

### The Old Way (Bare-Metal Hosting)
Historically, hosting a private game server required:
1. Installing SteamCMD on your operating system.
2. Manually downloading game binaries and C++ runtime libraries.
3. Setting up systemd services or batch files to keep the server alive.
4. Dealing with OS compatibility issues (especially on macOS or ARM processors).
5. Cluttering your computer with server files and dependencies that are hard to clean up.

### The Docker Way
Think of Docker as a **self-contained gaming console or portable sandbox inside your computer**:
* Everything the Valheim server needs (Linux operating system, SteamCMD, Valheim server files, backup tools) is packaged into a ready-to-run blueprint.
* The server runs inside an isolated bubble called a **container**.
* It leaves zero clutter on your personal computer and won't conflict with your other programs or games.
* Deleting or upgrading the server is as simple as running a single command.

---

## 🧱 The 3 Core Concepts

To understand how your server works, you only need to know three concepts:

| Concept | Real-World Analogy | Valheim Server Context |
| :--- | :--- | :--- |
| **Image** | The blueprint or game cartridge | `ghcr.io/community-valheim-tools/valheim-server`<br>The pre-packaged software containing Linux, SteamCMD, and startup scripts. |
| **Container** | The console running the cartridge | `valheim-server`<br>The active, living process where Valheim is currently running in memory. |
| **Volume** | The memory card | `./config` and `./data`<br>Folders on your actual computer's hard drive that are mapped into the container so your world saves and character progress survive restarts. |

---

## 📄 What is Docker Compose?

Docker Compose is a tool that allows you to configure your entire server using a single readable text file: [`docker-compose.yml`](../docker-compose.yml).

Instead of typing a long, complex command with dozens of flags every time you want to start your server, Docker Compose reads the file and configures:
- Which image to download.
- Which ports to open for players (`2456:2456/udp`, etc.).
- Your server's settings (server name, password, crossplay).
- Which folders on your hard drive to use for saves (`volumes`).
- Automatic restart behavior if your computer reboots.

With Docker Compose, you only ever need two commands:
* **Start**: `docker compose up -d`
* **Stop**: `docker compose down`

---

## 🍎 Running on Apple Silicon (M1, M2, M3, M4 Macs)

Valheim's dedicated server is compiled for standard PC x86/amd64 processors. Docker Desktop includes built-in emulation (Rosetta 2 / QEMU) that allows PC binaries to run seamlessly on Apple Silicon Macs.

In our [`docker-compose.yml`](configuration.md), the line:
```yaml
platform: linux/amd64
```
tells Docker to emulate standard PC hardware on your Mac so the game server runs smoothly without compatibility errors.

---

## 📚 Related Guides
- [Quick Start & Operations Guide](getting-started.md)
- [Playit.gg Zero-Port-Forwarding Tunnel](playit.md)
- [Server Configuration & `docker-compose.yml`](configuration.md)
- [How to Connect to Your Server](connecting.md)
- [Monitoring Logs with Dozzle](dozzle.md)
- [World Backups & Restoration](backups.md)
- [Troubleshooting & Admin Guide](troubleshooting.md)
