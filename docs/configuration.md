# 🔍 Server Configuration & `docker-compose.yml` Breakdown

This document provides a line-by-line explanation of the server configuration file [`docker-compose.yml`](../docker-compose.yml), explaining how settings are passed from environment variables into the container.

---

## 📄 The Full `docker-compose.yml` File

```yaml
services:
  valheim:
    image: ghcr.io/community-valheim-tools/valheim-server
    container_name: valheim-server
    platform: linux/amd64
    cap_add:
      - sys_nice
    security_opt:
      - seccomp=unconfined
    ports:
      - "${VALHEIM_PORT_1:-2456:2456/udp}"
      - "${VALHEIM_PORT_2:-2457:2457/udp}"
    environment:
      - SERVER_NAME=${SERVER_NAME:-My Valheim Server}
      - WORLD_NAME=${WORLD_NAME:-Dedicated}
      - SERVER_PASS=${SERVER_PASS:-secret1234} # Must be 5+ characters and NOT contained in the server name
      - SERVER_PUBLIC=${SERVER_PUBLIC:-false}
      - CROSSPLAY=${CROSSPLAY:-false} # Set to true if friends are playing on Xbox or PC Game Pass
      - STEAM_PLATFORM=${STEAM_PLATFORM:-linux64}
      - SERVER_ARGS=${SERVER_ARGS:--modifier Resources muchmore}
      - BACKUPS=${BACKUPS:-true}
      - "BACKUPS_CRON=${BACKUPS_CRON:-5 * * * *}"
      - BACKUPS_MAX_AGE=${BACKUPS_MAX_AGE:-3}
      - BACKUPS_MAX_COUNT=${BACKUPS_MAX_COUNT:-0}
      - BACKUPS_IF_IDLE=${BACKUPS_IF_IDLE:-true}
      - BACKUPS_IDLE_GRACE_PERIOD=${BACKUPS_IDLE_GRACE_PERIOD:-3600}
    volumes:
      - ./config:/config
      - ./data:/opt/valheim
    restart: unless-stopped

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

  playit:
    image: ghcr.io/playit-cloud/playit-agent:latest
    container_name: playit-agent
    network_mode: "service:valheim"
    environment:
      - SECRET_KEY=${PLAYIT_SECRET_KEY:-}
    volumes:
      - ./config/playit:/etc/playit
    depends_on:
      - valheim
    restart: unless-stopped
```

---

## 🧩 Detailed Line-by-Line Explanation

### Section 1: Service Basics

* **`services:`**  
  Tells Docker Compose that the following blocks define the individual services/applications to manage.

* **`  valheim:`**  
  The internal identifier for the Valheim service inside Docker Compose.

* **`    image: ghcr.io/community-valheim-tools/valheim-server`**  
  Specifies the Docker image to pull from GitHub Container Registry (`ghcr.io`). This community-maintained image (hosted on GitHub at [community-valheim-tools/valheim-server-docker](https://github.com/community-valheim-tools/valheim-server-docker)) includes:
  - SteamCMD for automatic game updates.
  - Automated world backup utilities.
  - Graceful shutdown scripts to prevent world corruption.

* **`    container_name: valheim-server`**  
  The human-friendly name displayed in Docker Desktop and in `docker ps` outputs.

* **`    platform: linux/amd64`**  
  Specifies the x86-64 Linux architecture. This enables Docker on Apple Silicon Macs (M1/M2/M3/M4) to run the x86 binary using Rosetta 2 / QEMU emulation seamlessly.

* **`    cap_add:`** & **`      - sys_nice`**  
  Grants Linux scheduling priority capabilities (`CAP_SYS_NICE`). This allows the server process to prioritize game tick calculations under high CPU load, reducing in-game rubberbanding.

* **`    security_opt:`** & **`      - seccomp=unconfined`**  
  Disables seccomp syscall filtering inside the container. This prevents permission conflicts when SteamCMD downloads and executes Linux binaries in an emulated environment.

---

### Section 2: Network Ports

* **`    ports:`**  
  Maps ports from your host computer into the container.

* **`      - "${VALHEIM_PORT_1:-2456:2456/udp}"`**  
  - `${VALHEIM_PORT_1:-...}` checks if an environment variable is set (via [`.env`](../.env) or shell). If unset, defaults to `2456:2456/udp`.
  - **Host Port (2456) : Container Port (2456)**: Traffic hitting port 2456 on your physical machine forwards directly to the server.
  - **UDP Protocol**: UDP provides low-latency transmission required for real-time game physics and combat.
  - **Function**: Primary game connection port.

* **`      - "${VALHEIM_PORT_2:-2457:2457/udp}"`**  
  - Steam Query port. Steam uses this port to check server health, query current player counts, and display the server in server browser lists.

> [!NOTE]  
> If you enable **Crossplay** (`CROSSPLAY=true`), you may also expose port **`2458:2458/udp`** if needed for direct connections, though players typically join via PlayFab Join Codes.

---

### Section 3: Environment Variables & Game Settings

The `environment` section configures the Valheim server runtime options:

| Variable | Default Value | Description |
| :--- | :--- | :--- |
| `SERVER_NAME` | `My Valheim Server` | The public name shown in the server list and in-game lobby. |
| `WORLD_NAME` | `Dedicated` | Name of your world save file. If no file with this name exists, a new world generates automatically. |
| `SERVER_PASS` | `secret1234` | Password required to join. See password rules below. |
| `SERVER_PUBLIC` | `false` | `true` lists the server in the public Steam lobby; `false` keeps it unlisted. |
| `CROSSPLAY` | `false` | Set to `true` to enable Microsoft PlayFab crossplay for Xbox and PC Game Pass players. |
| `STEAM_PLATFORM` | `linux64` | Target platform architecture for SteamCMD binaries (`linux64`). |
| `SERVER_ARGS` | `-modifier Resources muchmore` | Additional Valheim CLI arguments and world modifiers (defaults to 2x drop rate). |
| `PLAYIT_SECRET_KEY` | *(empty)* | Optional Playit.gg account secret key for headless authentication. Leave blank for web claiming. |
| `BACKUPS` | `true` | Enables or disables periodic automated backups. |
| `BACKUPS_CRON` | `5 * * * *` | Cron schedule for taking backups (default: hourly at minute 5). |
| `BACKUPS_MAX_AGE` | `3` | Maximum age in days to retain backups before purging. Increase this to keep backups longer. |
| `BACKUPS_MAX_COUNT` | `0` | Maximum number of backup archives to keep (`0` = unlimited). |
| `BACKUPS_IF_IDLE` | `true` | When `false`, pauses backup creation when no players are online to save space. |
| `BACKUPS_IDLE_GRACE_PERIOD` | `3600` | Grace period in seconds to keep backing up after the last player disconnects. |

> [!TIP]  
> **World Modifiers & Drop Rate (`SERVER_ARGS`):**  
> Valheim supports official world modifiers passed as launch arguments. The `SERVER_ARGS` variable passes flags directly to the Valheim server binary on startup.  
> To adjust the resource drop rate, use `-modifier Resources <value>`:
> - `muchless` — 0.5x drop rate
> - `less` — 0.75x drop rate
> - *(omitted / normal)* — 1.0x default drop rate
> - `more` — 1.5x drop rate
> - **`muchmore`** — **2.0x drop rate (doubles the default rate, active by default)**
> - `most` — 3.0x drop rate
> 
> You can also stack additional modifiers or preset flags in `SERVER_ARGS` (e.g. `SERVER_ARGS="-modifier Resources muchmore -modifier raids none"`).

> [!WARNING]  
> **Valheim Password Rules:**
> 1. Must be **at least 5 characters** long.
> 2. Must **NOT** appear inside `SERVER_NAME` (case-insensitive). For example, if your server name is `Odin Hall`, your password cannot be `Odin`.

---

### Section 4: Volumes (Data Persistence)

Docker containers are ephemeral: if a container is removed or updated, any files written inside it are lost. **Volumes** bridge folders on your physical hard drive into the container:

* **`    volumes:`**
  - **`./config:/config`**:  
    Maps the local [`config/`](../config) folder to `/config` in the container.
    - **Stores**: World saves (`worlds_local/`), admin list (`adminlist.txt`), banned/permitted lists, and automatic zip backups (`backups/`).
  - **`./data:/opt/valheim`**:  
    Maps the local [`data/`](../data) folder to `/opt/valheim` in the container.
    - **Stores**: The Valheim game server installation files (~1 GB). Because this is stored on your host drive, the server does not need to re-download the entire game every time it restarts.

---

### Section 5: Restart Reliability

* **`    restart: unless-stopped`**  
  Instructs Docker to automatically restart the server container if:
  - The Valheim server process crashes.
  - The Docker daemon restarts.
  - Your host computer reboots.
  
  The server will only remain stopped if you explicitly shut it down using `docker compose down` or the Docker Desktop interface.

---

### Section 6: Dozzle Web Log Viewer Service

The `dozzle` service block manages the real-time web console and container monitor:

* **`  dozzle:`**  
  The internal identifier for the Dozzle service within Docker Compose.

* **`    image: amir20/dozzle:latest`**  
  The official, ultra-lightweight (~7 MB) Dozzle image from Docker Hub.

* **`    container_name: dozzle`**  
  The container name shown in Docker Desktop and `docker compose ps`.

* **`    volumes:`** & **`      - /var/run/docker.sock:/var/run/docker.sock`**  
  Mounts the host Docker daemon socket into the Dozzle container. This allows Dozzle to stream logs and stats for all running containers and send lifecycle signals (start/stop/restart).

* **`    ports:`** & **`      - "${DOZZLE_PORT:-8080}:8080"`**  
  Maps the web UI to port `8080` by default (accessible at `http://localhost:8080`). You can customize the host port by setting `DOZZLE_PORT` in [`.env`](../.env).

* **`    environment:`** & **`      - DOZZLE_ENABLE_ACTIONS=true`**  
  Enables start, stop, restart, and image update action buttons directly in the Dozzle web interface.

* **`    restart: unless-stopped`**  
  Ensures Dozzle stays running and automatically recovers after a reboot or Docker daemon restart.

---

### Section 7: Playit.gg Zero-Port-Forwarding Tunnel Service

The `playit` service block manages the outbound encrypted tunnel that allows Internet players to connect without router port forwarding:

* **`  playit:`**  
  The internal identifier for the Playit tunnel service.

* **`    image: ghcr.io/playit-cloud/playit-agent:latest`**  
  The official `playit-agent` image from GitHub Container Registry, supporting both `amd64` and `arm64` (Apple Silicon).

* **`    container_name: playit-agent`**  
  The container name shown in Docker Desktop and Dozzle.

* **`    network_mode: "service:valheim"`**  
  Attaches the `playit-agent` container directly into the `valheim` container's network namespace. This allows Playit to target `127.0.0.1:2456` locally without Docker bridge IP discovery issues or publishing extra host ports.

* **`    environment:`** & **`      - SECRET_KEY=${PLAYIT_SECRET_KEY:-}`**  
  Passes the optional account secret key if defined in [`.env`](../.env). If empty, the agent boots into web claim mode and generates a claim URL in the container logs.

* **`    volumes:`** & **`      - ./config/playit:/etc/playit`**  
  Mounts the persistent configuration directory to store `playit.toml`. Once claimed, the agent remains permanently authenticated across container updates and system reboots.

* **`    depends_on:`** & **`      - valheim`**  
  Guarantees that the `valheim` container and its network stack are created before the agent attempts to bind to it.

* **`    restart: unless-stopped`**  
  Automatically restarts the tunnel agent if the connection drops or the host computer restarts.

---

## ⚙️ How Configuration Variables are Loaded

When you run `docker compose up -d`, variables are evaluated in this order of priority:
1. **Interactive Script ([`start.sh`](../start.sh))**: Interactively prompts you and exports values.
2. **Local [`.env`](../.env) file**: Written by `start.sh` so standard `docker compose` commands work across any shell session.
3. **Shell profile (`~/.bashrc`)**: Exported globally for persistent bash sessions.
4. **Fallback defaults**: Built directly into the `${VAR:-default}` syntax inside `docker-compose.yml`.

---

## 📚 Related Guides
- [Quick Start & Operations Guide](getting-started.md)
- [Playit.gg Zero-Port-Forwarding Tunnel](playit.md)
- [Docker Explained in Plain English](docker-explained.md)
- [How to Connect to Your Server](connecting.md)
- [Monitoring Logs with Dozzle](dozzle.md)
- [World Backups & Restoration](backups.md)
- [Troubleshooting & Admin Guide](troubleshooting.md)
