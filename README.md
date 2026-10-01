# 🛡️ Valheim Dedicated Server Guide (Beginner Friendly)

Welcome! This folder contains everything you need to run your very own private, dedicated **Valheim** server. 

Whether you want a persistent world for you and your friends so anyone can play even when you're offline, or you just want full control over your world saves, this guide will walk you through everything step-by-step—no programming experience required!

---

## 🧭 Table of Contents
1. [What is Docker? (In Plain English)](#-what-is-docker-in-plain-english)
2. [What You Need Before Starting](#-what-you-need-before-starting)
3. [Quick Start: Starting & Stopping the Server](#-quick-start-starting--stopping-the-server)
4. [Using Docker Desktop (No Commands Needed)](#-using-docker-desktop-the-point-and-click-way)
5. [Line-by-Line Breakdown of `docker-compose.yml`](#-line-by-line-breakdown-of-docker-composeyml)
6. [How to Connect to Your Server](#-how-to-connect-to-your-server)
7. [Backing Up Your World](#-backing-up-your-world)
8. [Troubleshooting & Frequently Asked Questions](#-troubleshooting--faq)

---

## 💡 What is Docker? (In Plain English)

Normally, installing a dedicated game server means installing SteamCMD, downloading runtime libraries, setting up firewall rules, and configuring background services on your operating system.

**Docker** changes that. Think of Docker as a **self-contained gaming console inside your computer**:
* It downloads a ready-made "blueprint" (called an **image**) that has Valheim, Steam, and all necessary tools pre-installed.
* When you run it, it boots inside a safe, isolated bubble (called a **container**).
* It won't clutter your computer with extra software or conflict with your other files.
* **Docker Compose** is simply a tool that reads our single settings sheet ([`docker-compose.yml`](file:///Users/jameslarson/Projects/valheim/docker-compose.yml)) and turns the server on or off with one command.

---

## 📋 What You Need Before Starting

1. **Docker Desktop installed and running**:
   - Download it for Mac or Windows from [docker.com](https://www.docker.com/products/docker-desktop/).
   - Make sure Docker Desktop is open. You should see a small whale icon in your Mac menu bar (top right) or Windows system tray (bottom right).
2. **Terminal (Mac) or PowerShell / Command Prompt (Windows)**:
   - On Mac: Press `Cmd + Space`, type `Terminal`, and press `Enter`.
   - On Windows: Press `Windows Key`, type `PowerShell`, and press `Enter`.

---

## 🚀 Quick Start: Starting & Stopping the Server

### 1. Open Terminal in this folder
In your Terminal or PowerShell window, navigate to this project folder. For example:
```bash
cd /Users/jameslarson/Projects/valheim
```
*(Tip: On Mac, you can type `cd ` and drag this folder directly from Finder into your Terminal window!)*

---

### 2. Start the server
To start the server, run:
```bash
docker compose up -d
```

> **What does `-d` mean?**  
> It stands for "detached". It means the server will run quietly in the background, freeing up your Terminal window so you can close it without shutting down the server.

The very first time you run this, Docker will download the necessary files (around 1–2 GB). Once finished, your server is booting up!

---

### 3. Check if the server is running
Run:
```bash
docker compose ps
```
Look at the **STATUS** column. If it says `Up`, your server is running.

---

### 4. View server logs (See what the server is doing)
To watch the server boot up or see player connections:
```bash
docker compose logs -f
```

> **How to exit the log view:**  
> Press `Ctrl + C` on your keyboard. This stops *watching* the logs—it does **not** stop the server.

> [!NOTE]  
> When you first start the server, it usually takes **2 to 4 minutes** to download the latest Valheim game updates from Steam and generate the world. Wait until you see a log line mentioning `Game server connected` before trying to join.

---

### 5. Stop the server safely
When you're ready to shut down the server, run:
```bash
docker compose down
```

> [!IMPORTANT]  
> Always use `docker compose down` (or the Stop button in Docker Desktop). This sends a clean shutdown signal to Valheim so it saves your world and character progress safely before closing.

---

### 6. Updating the server
When Iron Gate releases a new Valheim patch, update your server easily:
```bash
docker compose pull
docker compose up -d
```
Docker will grab the latest update and restart the server automatically.

---

## 🖱️ Using Docker Desktop (The Point-and-Click Way)

If you prefer not using the command line, you can control everything using the **Docker Desktop** app:

1. Open **Docker Desktop**.
2. Click on the **Containers** tab on the left sidebar.
3. You will see an entry named `valheim` (or `valheim-server`).
4. **To start**: Click the green **Play** button (▶️).
5. **To stop**: Click the square **Stop** button (⏹️).
6. **To see logs**: Click on the container name to view live console output.

---

## 🔍 Line-by-Line Breakdown of `docker-compose.yml`

Here is the exact [`docker-compose.yml`](file:///Users/jameslarson/Projects/valheim/docker-compose.yml) file running your server, with an explanation for every single line:

```yaml
1: services:
2:   valheim:
3:     image: ghcr.io/community-valheim-tools/valheim-server
4:     container_name: valheim-server
5:     platform: linux/amd64
6:     ports:
7:       - "2456:2456/udp"
8:       - "2457:2457/udp"
9:     environment:
10:       - SERVER_NAME=My Valheim Server
11:       - WORLD_NAME=Dedicated
12:       - SERVER_PASS=secret1234 # Must be 5+ characters and NOT contained in the server name
13:       - SERVER_PUBLIC=true
14:       - CROSSPLAY=false # Set to true if friends are playing on Xbox or PC Game Pass
15:     volumes:
16:       - ./config:/config
17:       - ./data:/opt/valheim
18:     restart: unless-stopped
```

---

### Section 1: The Basics (Lines 1–5)

* **`services:`** (Line 1)  
  Tells Docker: *"Here is the list of programs/services I want you to run."*

* **`  valheim:`** (Line 2)  
  The internal nickname for this service in Docker Compose.

* **`    image: ghcr.io/community-valheim-tools/valheim-server`** (Line 3)  
  This tells Docker where to download the pre-built server package from. It uses the popular, actively maintained community image hosted on GitHub's Container Registry (`ghcr.io`). It comes pre-configured with SteamCMD, automated backup support, and clean startup scripts.

* **`    container_name: valheim-server`** (Line 4)  
  The friendly display name that shows up in the Docker Desktop application list.

* **`    platform: linux/amd64`** (Line 5)  
  Valheim's dedicated server is built for standard x86/amd64 PC processors. If you are on an Apple Silicon Mac (M1, M2, M3, M4), this line instructs Docker to emulate an x86 PC environment so the game server runs smoothly without errors.

---

### Section 2: Network Ports (Lines 6–8)

* **`    ports:`** (Line 6)  
  Think of ports as "doors" or "channels" into your computer. By default, Docker containers are isolated from your home network. This section opens specific doors so Valheim players can talk to your server.

* **`      - "2456:2456/udp"`** (Line 7)  
  * **2456 (Host) : 2456 (Container)**: Forwards traffic from your computer's port 2456 into the container's port 2456.
  * **UDP**: The network protocol games use for fast, real-time player movement and combat.
  * **Purpose**: This is the primary game port players connect to.

* **`      - "2457:2457/udp"`** (Line 8)  
  The Steam Query port. Steam uses this port to ping your server, check player count, and display it in server lists.

> [!NOTE]  
> If you enable **Crossplay** (`CROSSPLAY=true`), you will also need to add port **2458:2458/udp** under `ports:` so console players can connect.

---

### Section 3: Game Settings & Configuration (Lines 9–14)

* **`    environment:`** (Line 9)  
  These are the customizable knobs and dials passed into the Valheim server on startup.

* **`      - SERVER_NAME=My Valheim Server`** (Line 10)  
  The public title of your server as it appears in the game's server browser. Feel free to rename this to anything you like (e.g., `Odin's Playground`).

* **`      - WORLD_NAME=Dedicated`** (Line 11)  
  The name of your save file. If no world with this name exists, the server will automatically generate a brand new world with this name. If you have an existing world you want to transfer, you would match this name to your save file.

* **`      - SERVER_PASS=secret1234`** (Line 12)  
  The password required for players to join.  
  > [!WARNING]  
  > **Valheim Rules for Passwords:**  
  > 1. Must be **at least 5 characters** long.  
  > 2. Must **NOT** appear inside your `SERVER_NAME`. (For example, if your server name is `Valheim Server`, your password cannot be `Server`).

* **`      - SERVER_PUBLIC=true`** (Line 13)  
  * `true`: Shows your server on the public Valheim/Steam community server list.  
  * `false`: Hides it from the public list. Players can still join directly if they know your IP address.

* **`      - CROSSPLAY=false`** (Line 14)  
  * `false`: Only players on Steam (PC/Mac/Linux) can join.  
  * `true`: Enables Microsoft PlayFab crossplay, allowing friends on Xbox or PC Game Pass to join using a 6-digit Join Code.

---

### Section 4: Data Storage & Persistence (Lines 15–17)

Docker containers are temporary—if you delete a container, everything inside it is erased. **Volumes** solve this by linking a folder on your real hard drive into the container:

* **`    volumes:`** (Line 15)  
  Starts the persistent storage mappings.

* **`      - ./config:/config`** (Line 16)  
  * Links the local [`config`](file:///Users/jameslarson/Projects/valheim/config) folder on your computer to `/config` inside the container.
  * **What goes here?** Your world save files (`worlds_local/`), admin lists (`adminlist.txt`), permitted player lists, and automatic server backups.

* **`      - ./data:/opt/valheim`** (Line 17)  
  * Links the local [`data`](file:///Users/jameslarson/Projects/valheim/data) folder on your computer to `/opt/valheim` inside the container.
  * **What goes here?** The actual Valheim game installation files downloaded from Steam. Because these are saved here, the server doesn't need to re-download the entire 1 GB game every time it restarts.

---

### Section 5: Reliability (Line 18)

* **`    restart: unless-stopped`** (Line 18)  
  Tells Docker: *"If the game crashes or your computer restarts, automatically turn the Valheim server back on."*  
  The only time it will stay off is if you deliberately stopped it using `docker compose down` or Docker Desktop.

---

## 🎮 How to Connect to Your Server

### 1. Playing on the Same Computer Hosting the Server
1. Launch **Valheim**.
2. Click **Start Game**, select your character.
3. Click the **Join Game** tab.
4. Click **Join IP** (at the bottom).
5. Enter: `127.0.0.1:2456` or `localhost:2456`.
6. Enter your password (`secret1234`).

---

### 2. Friends on the Same Home Wi-Fi / Local Network (LAN)
1. Find your computer's local IP address:
   - **Mac**: System Settings > Wi-Fi > Details > Look for `IP address` (e.g. `192.168.1.45`).
   - **Windows**: Settings > Network & Internet > Properties > Look for `IPv4 address`.
2. Have your friends click **Join IP** in Valheim and enter:
   ```text
   <YOUR-LOCAL-IP>:2456
   ```
   *(Example: `192.168.1.45:2456`)*

---

### 3. Friends Connecting Over the Internet
To let friends outside your house join:

1. **Port Forwarding on your Router**:
   - Log in to your home Wi-Fi router's admin settings (typically `192.168.1.1` or `192.168.0.1` in your browser).
   - Find the **Port Forwarding** section.
   - Forward ports **2456** and **2457** (Protocol: **UDP**) to your hosting computer's local IP address.
   - *(If using Crossplay, also forward port **2458** UDP).*
2. **Find your Public IP**:
   - Google ["what is my ip"](https://www.google.com/search?q=what+is+my+ip).
3. **Give your friends**:
   ```text
   <YOUR-PUBLIC-IP>:2456
   ```

---

## 💾 Backing Up Your World

Nothing is worse than losing 100 hours of Viking architecture! Here's how to keep your world safe:

### Automatic Backups
The server image has **built-in automatic backups**. It creates zip archives of your world automatically and saves them in:
```text
config/backups/
```

### Manual Backup (Before Updates or Experiments)
1. Stop the server (`docker compose down`).
2. Copy the entire [`config`](file:///Users/jameslarson/Projects/valheim/config) folder.
3. Paste it to a safe place (like your Desktop, Google Drive, or an external drive).
4. Start the server back up (`docker compose up -d`).

If you ever need to restore:
Your active world save files are located inside:
```text
config/worlds_local/
```
They consist of two files: `Dedicated.db` and `Dedicated.fwl`. To restore an old save, simply replace those two files with your backup copies while the server is stopped.

---

## ❓ Troubleshooting & FAQ

### "I changed the server name or password, but it didn't update"
Any time you edit [`docker-compose.yml`](file:///Users/jameslarson/Projects/valheim/docker-compose.yml), tell Docker to apply your changes by running:
```bash
docker compose up -d
```
Docker will detect the change, restart the container, and use your new settings.

### "Docker says: Cannot connect to the Docker daemon"
This simply means **Docker Desktop is not currently running**. Open the Docker Desktop app from your Applications/Start Menu, wait 10 seconds for the little whale icon to turn steady, and try your command again.

### "My friends can't see or connect to the server"
1. **Patience**: When the server first starts, it can take 2–3 minutes to register with Steam. Run `docker compose logs -f` and wait until you see `Game server connected`.
2. **Password rule**: Verify that your password has 5+ characters and does not appear within the server name.
3. **Firewall / Port Forward**: Ensure UDP ports 2456 and 2457 are forwarded on your router to your host computer.
4. **Mac Firewall**: Go to System Settings > Network > Firewall, and ensure incoming connections for Docker are allowed.

### "How do I make myself an Admin?"
1. Open the file `config/adminlist.txt` in a text editor (this file is created after the server runs for the first time).
2. Add your **Steam64 ID** (a 17-digit number you can find on [steamid.io](https://steamid.io/)) on a new line.
3. Save the file. You will now have access to in-game admin console commands (`F5`).

---

*Skål and happy exploring in the Tenth Realm!* 🪓⛵
