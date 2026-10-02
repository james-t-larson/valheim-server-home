# ❓ Troubleshooting & Administrator Guide

This guide covers common issues, server errors, network connection checks, and instructions for granting admin privileges.

---

## 👑 How to Make Yourself an Admin

Admins can kick/ban bad actors and use in-game console commands.

1. **Find your Steam64 ID**:
   - Go to [steamid.io](https://steamid.io/) and enter your Steam profile link or username.
   - Look for the 17-digit number labeled **steamID64** (e.g., `76561198000000000`).
2. **Open the Admin List**:
   - Once the server has run at least once, open the file:
     ```text
     config/adminlist.txt
     ```
3. **Add your Steam64 ID**:
   - Enter your 17-digit ID on its own line:
     ```text
     76561198000000000
     ```
4. **Save the file**:
   - Changes take effect immediately or upon player reconnect.
5. **Open Console in Valheim**:
   - In your Steam library, right-click **Valheim** > **Properties** > Add `-console` to **Launch Options**.
   - In game, press `F5` to open the admin console. Type `help` to list commands.

---

## 🛠️ Common Issues & Fixes

### 1. "Docker says: Cannot connect to the Docker daemon"
* **Cause**: Docker Desktop is not running or the engine is still initializing.
* **Fix**:
  1. Open the **Docker Desktop** application from Applications (macOS) or the Start Menu (Windows).
  2. Wait 15–30 seconds until the Docker whale icon in the menu bar or system tray becomes steady.
  3. Re-run your command (`./start.sh` or `docker compose up -d`).

---

### 2. "I changed my settings, but the server didn't update"
* **Cause**: Changing variables in `.bashrc` or editing files requires Docker Compose to recreate the container.
* **Fix**:
  1. Update settings via [`start.sh`](../start.sh) or directly edit [`.env`](../.env).
  2. Apply the updates:
     ```bash
     docker compose up -d
     ```
  3. Docker will detect the modified environment variables and recreate the container automatically without deleting world data.

---

### 3. "Friends cannot find or connect to the server"
Run through this 4-step checklist:

1. **Check Startup Progress**:
   - When the server boots for the first time or downloads Steam updates, it takes **2 to 4 minutes** before opening network sockets.
   - Run `docker compose logs -f` or check [Dozzle](dozzle.md). Wait until you see:
     ```text
     Game server connected
     ```
2. **Verify Password Requirements**:
   - The password **must** be at least 5 characters.
   - The password **must NOT** appear inside your `SERVER_NAME` (case-insensitive). For example, if your server name is `Viking Land`, the password cannot be `Viking`.
3. **Check Connection Route**:
   - **Using Playit.gg (Recommended)**: Verify the agent is connected with `docker compose logs playit` or in [Dozzle](dozzle.md). Make sure your Playit tunnel points to `127.0.0.1:2456` (UDP) and players join using **Join IP** with the complete domain and port. See the **[Playit.gg Tunnel Guide](playit.md)**.
   - **Using Direct Port Forwarding**: Ensure UDP ports **2456** and **2457** (and **2458** if using Crossplay) are forwarded to your host computer's local IP address on your home router. Protocol must be **UDP** (not only TCP).
4. **Check Host Machine Firewall**:
   - **macOS**: Go to **System Settings** > **Network** > **Firewall**. Ensure incoming connections for Docker are allowed or temporarily toggle off for testing.
   - **Windows**: Check **Windows Defender Firewall** > Allow Docker Desktop through public and private networks.

---

### 4. "Container keeps restarting or says 'Exited (1)'"
* **Check the logs**:
  ```bash
  docker compose logs --tail=100
  ```
  *(or inspect logs in [Dozzle](dozzle.md))*.
* **Common causes**:
  - **Password conflict**: Check if password violates the server name rule.
  - **Port collision**: Another process on your computer is using UDP port 2456 or 2457.
  - **Permissions**: Verify Docker has read/write permissions to the [`config`](../config) and [`data`](../data) folders.

---

## 📚 Related Guides
- [Quick Start & Operations Guide](getting-started.md)
- [Playit.gg Zero-Port-Forwarding Tunnel](playit.md)
- [Docker Explained in Plain English](docker-explained.md)
- [Server Configuration & `docker-compose.yml`](configuration.md)
- [How to Connect to Your Server](connecting.md)
- [Monitoring Logs with Dozzle](dozzle.md)
- [World Backups & Restoration](backups.md)
