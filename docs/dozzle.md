# 📊 Monitoring Server Logs with Dozzle

[Dozzle](https://dozzle.dev) is a lightweight, open-source, real-time log viewer and container stats monitor for Docker. It provides a clean, responsive web interface that streams your Valheim server logs directly to your browser—no command line or `docker compose logs -f` needed!

---

## ✨ Why Use Dozzle?

* **Live Log Streaming**: Watch Valheim server boot progress, world generation, and player joins/leaves in real time.
* **Instant Search & Regex Filtering**: Filter thousands of log lines instantly to diagnose issues or find specific player actions.
* **Live Stats**: View real-time CPU and RAM utilization for your containers.
* **Lightweight**: Uses negligible system resources (~7 MB container size) with zero database overhead.
* **Multi-Container Support**: Switch seamlessly between `valheim-server` and any other Docker containers.
* **Dark Mode & Split Screen**: Clean interface with log split-screening.

---

## 🚀 Starting Dozzle

Dozzle is built directly into [`docker-compose.yml`](../docker-compose.yml) and starts automatically whenever you launch the Valheim server!

### Automatic Startup with Docker Compose (Default)

Whenever you start your server with `./start.sh` or `docker compose up -d`, Docker Compose starts both `valheim-server` and `dozzle` together in the background:

```bash
docker compose up -d
```

Both containers will start up, and Dozzle will immediately begin streaming server output.

#### Compose Configuration
Here is the `dozzle` service definition pre-configured in [`docker-compose.yml`](../docker-compose.yml):

```yaml
services:
  # ... valheim service ...

  dozzle:
    image: amir20/dozzle:latest
    container_name: dozzle
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
    ports:
      - "${DOZZLE_PORT:-8080}:8080"
    environment:
      - DOZZLE_ENABLE_ACTIONS=true
    restart: unless-stopped
```

#### What this configuration does:
* **`image: amir20/dozzle:latest`**: Pulls the official, lightweight image from Docker Hub.
* **`container_name: dozzle`**: Names the container `dozzle` for easy identification.
* **`volumes: - /var/run/docker.sock:/var/run/docker.sock`**: Mounts the host Docker socket so Dozzle can read container events and send lifecycle commands (start/stop/restart).
* **`ports: - "${DOZZLE_PORT:-8080}:8080"`**: Forwards port `8080` (or your custom `DOZZLE_PORT` from `.env`) from your host computer into the container.
* **`environment: - DOZZLE_ENABLE_ACTIONS=true`**: **Enables container management in the web UI** (Start, Stop, Restart, and Update).
* **`restart: unless-stopped`**: Automatically restarts Dozzle if it crashes or when your system reboots.

---

### Alternative: Standalone Docker Run Command

If you ever wish to run Dozzle outside Docker Compose as an independent container, you can launch it with:

```bash
docker run --name dozzle -d \
  --volume=/var/run/docker.sock:/var/run/docker.sock \
  -p 8080:8080 \
  -e DOZZLE_ENABLE_ACTIONS=true \
  amir20/dozzle:latest
```

---

## 🎮 Container Actions from the Web UI

When `--enable-actions` (or `DOZZLE_ENABLE_ACTIONS=true`) is active, Dozzle displays action buttons next to each container in the web interface:

* **▶️ Start**: Turn on stopped containers without opening terminal or Docker Desktop.
* **⏹️ Stop**: Gracefully send a stop signal to containers.
* **🔄 Restart**: Quickly restart a container (e.g. after changing settings).
* **⬆️ Update**: Check and pull the newest container image.

> [!IMPORTANT]  
> For container actions to work, `/var/run/docker.sock` must be mounted with write permissions (i.e. **without** the `:ro` read-only flag), because Docker requires write access to execute container lifecycle commands.

---

## 🌐 How to Access Dozzle from a Local Machine

Once the Dozzle container is running, you can access its web interface from your local machines:

### 1. From the Host Computer (Same Machine Running Docker)

1. Open any web browser (Chrome, Safari, Firefox, Edge, Brave).
2. In the address bar, navigate to:
   ```text
   http://localhost:8080
   ```
   *(or `http://127.0.0.1:8080`)*
3. You will immediately see the Dozzle dashboard listing all active containers.
4. Click on **`valheim-server`** to watch the live console logs.

---

### 2. From Another Computer or Device on Your Local Network (LAN)

If you are hosting Valheim on a desktop, Mac mini, or home server, and want to monitor logs from your laptop, tablet, or smartphone connected to the same home Wi-Fi:

#### Step 1: Find the Host Machine's Local IP Address
On the computer running Docker:
* **macOS**:
  - Run in Terminal:
    ```bash
    ipconfig getifaddr en0
    ```
    *(Use `en1` if on wired Ethernet).*
  - Or go to **System Settings** > **Wi-Fi** (or **Network**) > Click **Details...** next to your connected network. Look for **IP address** (e.g. `192.168.1.45`).
* **Windows**:
  - Open PowerShell / Command Prompt and run:
    ```cmd
    ipconfig
    ```
  - Look for the **IPv4 Address** under your active connection (e.g. `192.168.1.45`).
* **Linux**:
  - Run `hostname -I` in your terminal.

#### Step 2: Open Dozzle in the Browser of Your Other Device
1. On your laptop, tablet, or phone (connected to the same Wi-Fi network), open a browser.
2. Navigate to:
   ```text
   http://<HOST-LOCAL-IP>:8080
   ```
   *Example: `http://192.168.1.45:8080`*
3. You can now monitor Valheim logs and container health remotely from your couch or desk!

> [!NOTE]  
> If the page does not load from a second local machine:
> * Ensure both devices are connected to the same local network (e.g., not one on guest Wi-Fi and one on main Wi-Fi).
> * Check your host machine's firewall settings (macOS **System Settings > Network > Firewall** or **Windows Defender Firewall**) to ensure incoming connections on port `8080` are allowed.

---

## 💡 Valheim Milestones to Look For in Dozzle

When reviewing logs in Dozzle:

1. **Server Ready**: Look for the log line:
   ```text
   Game server connected
   ```
   This indicates that SteamCMD has verified the game files and the server is actively accepting player connections.
2. **Player Joins**: Look for:
   ```text
   Got handshake from client <SteamID>
   ...
   Player <Name> joined the game
   ```
3. **World Auto-Saves**: Look for:
   ```text
   World save started ... World saved in ... ms
   ```

---

## 🛠️ Management & Customization Tips

### Changing the Port
If port `8080` is already used by another application on your computer:
* **With Docker Compose**:
  Add or edit `DOZZLE_PORT` in your [`.env`](../.env) file:
  ```dotenv
  DOZZLE_PORT=8888
  ```
  Then recreate the Dozzle container:
  ```bash
  docker compose up -d dozzle
  ```
* **With Standalone Docker**:
  ```bash
  docker run --name dozzle -d \
    --volume=/var/run/docker.sock:/var/run/docker.sock \
    -p 8888:8080 \
    -e DOZZLE_ENABLE_ACTIONS=true \
    amir20/dozzle:latest
  ```
* Access Dozzle at `http://localhost:8888` (or `http://<HOST-IP>:8888`).

### Managing Dozzle with Docker Compose
* **View Dozzle logs**: `docker compose logs -f dozzle`
* **Restart Dozzle**: `docker compose restart dozzle`
* **Stop Dozzle only**: `docker compose stop dozzle`
* **Start Dozzle only**: `docker compose start dozzle`

### Read-Only Mode (View-Only / Disables Actions)
If you prefer Dozzle to have strictly view-only access without container management buttons:
* In [`docker-compose.yml`](../docker-compose.yml), remove `DOZZLE_ENABLE_ACTIONS=true` (or set it to `false`), and mount the socket with `:ro`:
  ```yaml
  volumes:
    - /var/run/docker.sock:/var/run/docker.sock:ro
  ```
* Or in standalone Docker:
  ```bash
  docker run --name dozzle -d \
    --volume=/var/run/docker.sock:/var/run/docker.sock:ro \
    -p 8080:8080 \
    amir20/dozzle:latest
  ```

---

## 📚 Related Guides
- [Quick Start & Operations Guide](getting-started.md)
- [Server Configuration & `docker-compose.yml`](configuration.md)
- [How to Connect to Your Server](connecting.md)
- [World Backups & Restoration](backups.md)
- [Troubleshooting & Admin Guide](troubleshooting.md)
