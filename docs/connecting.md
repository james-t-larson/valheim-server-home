# 🎮 How to Connect to Your Valheim Server

Depending on whether you are playing on the same machine hosting the server, from another computer on the same local Wi-Fi, or over the public Internet, follow the instructions below.

---

## 🖥️ 1. Connecting on the Same Computer (Host Machine)

If you are running Valheim on the exact same computer that is hosting the Docker container:

1. Launch **Valheim**.
2. Select your character and click **Start Game**.
3. Click the **Join Game** tab at the top.
4. Click the **Join IP** button at the bottom of the screen.
5. Enter:
   ```text
   127.0.0.1:2456
   ```
   *(or `localhost:2456`)*
6. Enter your server password (default: `secret1234`).

---

## 🏠 2. Friends on the Same Local Network (Home Wi-Fi / LAN)

If friends or family are connected to the same home Wi-Fi router or local network:

### Step 1: Find the Host Computer's Local IP Address
On the computer running the Docker server:
* **macOS**:
  - Open **Terminal** and run:
    ```bash
    ipconfig getifaddr en0
    ```
    *(If connected via Wi-Fi, `en0` is typically the interface. If connected via Ethernet cable, try `en1`).*
  - Alternatively: Open **System Settings** > **Wi-Fi** (or **Network**) > Click **Details...** next to your active connection. Look for **IP address** (e.g., `192.168.1.45`).
* **Windows**:
  - Open **PowerShell** or **Command Prompt** and run:
    ```cmd
    ipconfig
    ```
  - Look for the **IPv4 Address** under your active network adapter (e.g., `192.168.1.45`).
* **Linux**:
  - Run `hostname -I` or `ip addr show`.

### Step 2: Connect from the Second Machine
1. Launch **Valheim** on the other computer.
2. Go to **Join Game** > **Join IP**.
3. Enter the host machine's local IP address and port:
   ```text
   <HOST-LOCAL-IP>:2456
   ```
   *Example: `192.168.1.45:2456`*
4. Enter the server password.

---

## 🌐 3. Friends Connecting Over the Internet

To allow friends outside your home to connect:

### Step 1: Configure Port Forwarding on Your Router
Because home routers block incoming traffic by default, you must tell your router to forward Valheim game packets to the specific computer running your Docker server:
1. Open a web browser and log into your router's administration interface (typically `http://192.168.1.1` or `http://192.168.0.1`).
2. Locate the **Port Forwarding** (or **Virtual Server**) section in router settings.
3. Add a new port forwarding rule with:
   - **Internal IP**: The host computer's local IP address (e.g., `192.168.1.45`).
   - **Port Range**: `2456` to `2457` (or single entries for `2456` and `2457`).
   - **Protocol**: **UDP** (or UDP/TCP).
   - *(If using Crossplay, also forward port **2458** UDP).*
4. Save and apply the settings.

### Step 2: Find Your Public IP Address
On the host machine, find your home's public Internet IP address:
* Visit [icanhazip.com](https://icanhazip.com) or search Google for `what is my ip`.

### Step 3: Give Your Friends the Connection Details
Tell your friends to join using:
```text
<YOUR-PUBLIC-IP>:2456
```
*(Example: `73.189.42.10:2456`)*

---

## 🎮 4. Crossplay (Xbox & PC Game Pass)

If your server has crossplay enabled (`CROSSPLAY=true` in [`docker-compose.yml`](configuration.md)):
1. Start the server and view the logs:
   ```bash
   docker compose logs -f
   ```
2. Look for the line containing your **PlayFab Join Code** (a 6-digit alphanumeric code):
   ```text
   Session "My Valheim Server" with join code 123456 and IP ... is active
   ```
3. Players on Xbox, PC Game Pass, or Steam can join using this **Join Code** in the Valheim Join Game menu.

---

## 📚 Related Guides
- [Quick Start & Operations Guide](getting-started.md)
- [Server Configuration & `docker-compose.yml`](configuration.md)
- [Monitoring Logs with Dozzle](dozzle.md)
- [World Backups & Restoration](backups.md)
- [Troubleshooting & Admin Guide](troubleshooting.md)
