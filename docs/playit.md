# 🛡️ Playit.gg Zero-Port-Forwarding Tunnel Guide

This guide explains how to use **[playit.gg](https://playit.gg)** with your Valheim dedicated server to allow friends across the Internet to connect without configuring router port forwarding, dealing with CGNAT, or exposing your home IP address.

---

## 🌟 Why Use Playit.gg?

Traditional game hosting requires logging into your home router and configuring UDP port forwarding (`2456:2457`). However, in many situations, port forwarding is difficult or impossible:

* **CGNAT (Carrier-Grade NAT):** Common with cellular 5G home internet (T-Mobile, Verizon Home), Starlink, and many fiber/cable ISPs where you share a public IP with other households.
* **Restricted Networks:** University dorms, apartment complexes, or shared office Wi-Fi where you do not have administrative router access.
* **Privacy & Security:** Playit shields your physical home IP address behind Playit's global Anycast proxy network, mitigating DDoS attacks and IP leaking.
* **Persistent Hostname:** Players connect using a friendly domain name (e.g. `hearth-viking.gl.at.ply.gg:28491`) instead of your home IP address.

---

## 🏗️ Architecture: Network Sidecar (`network_mode: "service:valheim"`)

The `playit-agent` is deployed as a **network sidecar** container directly attached to the Valheim container's network stack:

```text
+---------------------------------------------------------------------------------+
|                                  Host Machine                                   |
|                                                                                 |
|   +-------------------------------------------------------------------------+   |
|   |                  Shared Network Stack (service:valheim)                 |   |
|   |                                                                         |   |
|   |   +------------------------+          +-----------------------------+   |   |
|   |   |     valheim-server     |   UDP    |        playit-agent         |   |   |
|   |   |  (Listening on :2456)  |<---------|   (ghcr.io/playit-cloud)    |   |   |
|   |   +------------------------+ 127.0.0.1+-----------------------------+   |   |
|   +------------------------------------------------------|------------------+   |
|                                                          | Outbound Encrypted   |
|                                                          | UDP/TCP Control      |
+----------------------------------------------------------|----------------------+
                                                           v
                                                +---------------------+
                                                |    playit.gg edge   |
                                                |   (Anycast Network) |
                                                +---------------------+
                                                           ^
                                                           | "Join IP"
                                                +---------------------+
                                                |    Remote Players   |
                                                +---------------------+
```

### Why this design works seamlessly:
1. **Localhost Routing (`127.0.0.1:2456`)**: Because both containers share the exact same network namespace, Playit forwards incoming traffic directly to `127.0.0.1:2456`. You don't need internal Docker DNS resolution or bridge IP routing.
2. **Outbound Only**: The agent initiates an outbound encrypted tunnel to Playit's edge servers. Your firewall blocks no incoming traffic because all incoming connections are received inside the established outbound tunnel.
3. **Local LAN Still Works**: The host ports (`2456:2456/udp`) on the `valheim` container remain untouched, meaning players on your local home Wi-Fi can still connect directly via your local IP without going through the Internet.

---

## 🚀 Setup Workflows

You can configure Playit using either **Web Claiming** (quickest for first-time users) or **Headless Secret Key** (fully automated).

---

### Mode 1: Web Claiming via Dozzle or Logs (Recommended for Beginners)

When you first launch the server without a secret key, `playit-agent` generates a one-time web claim link.

#### Step 1: Start the server
Run `./start.sh` (press Enter on step 9 to leave the key blank) or run:
```bash
docker compose up -d
```

#### Step 2: Get the Claim URL
You can retrieve your claim URL using either:
* **Option A: Web Browser via Dozzle (Easiest)**:
  1. Open [http://localhost:8080](http://localhost:8080).
  2. Click **`playit-agent`** in the container list.
  3. Look for the claim notice:
     ```text
     Visit to claim agent: https://playit.gg/claim/xxxxxxxx-xxxx
     ```
* **Option B: Terminal CLI**:
  ```bash
  docker compose logs playit
  ```

#### Step 3: Claim Your Agent
1. Click or copy the claim link into your browser.
2. Log into or create a free account at [playit.gg](https://playit.gg).
3. Confirm claiming the agent. Once claimed, Playit will save its authentication credentials to `./config/playit/playit.toml` on your computer so it stays authenticated across reboots.

#### Step 4: Create the Valheim Tunnel
In the Playit.gg web dashboard for your newly claimed agent:
1. Click **Add Tunnel**.
2. Set **Tunnel Type** to **UDP**.
3. Set **Local IP / Target** to:
   ```text
   127.0.0.1
   ```
4. Set **Port** to:
   ```text
   2456
   ```
5. Click **Create Tunnel**.

#### Step 5: Copy Your Public Address
Your tunnel page will display your public connection address, for example:
```text
hearth-viking.gl.at.ply.gg:28491
```
Share this address and your server password with your friends!

---

### Mode 2: Headless Single Command (Zero Browser Interaction on Host)

If you already have a Playit account or manage your server headlessly:

1. Go to your [Playit Agent Wizard](https://playit.gg/account/setup/wizard/new-account) or create a secret key under your existing account.
2. Copy the generated **Secret Key**.
3. Add it to [`.env`](../.env):
   ```dotenv
   PLAYIT_SECRET_KEY="your_secret_key_here"
   ```
   *(Or enter it when prompted during `./start.sh`).*
4. Run:
   ```bash
   docker compose up -d
   ```
The agent immediately authenticates and activates all tunnels registered to that key.

---

## 🎮 How Players Connect in Valheim

Because Playit maps your server to a unique public domain and port:

1. Launch **Valheim**.
2. Select your character and choose **Join Game**.
3. Click the **Join IP** button at the bottom of the screen.
4. Enter the full Playit address including the port:
   ```text
   <subdomain>.gl.at.ply.gg:<port>
   ```
   *Example: `hearth-viking.gl.at.ply.gg:28491`*
5. Click **Connect** and enter the server password.

> [!NOTE]
> The server will **not** appear in the in-game Steam Community Server list because the Steam query port (`2457`) is not contiguously paired with the assigned high port on free Playit tunnels. Players must use the **Join IP** button.

---

## ⚖️ Playit.gg vs. Native Crossplay (`CROSSPLAY=true`)

Valheim includes native NAT punchthrough via Microsoft PlayFab. Here is how the two approaches compare:

| Dimension | Playit.gg Tunnel | Native Crossplay (`CROSSPLAY=true`) |
| :--- | :--- | :--- |
| **Router Port Forwarding Required?** | **No** | **No** |
| **How Players Connect** | Direct Join via Domain:Port (`name.ply.gg:12345`) | 6-Digit Alphanumeric Join Code (`482910`) |
| **Supported Clients** | PC / Steam | PC, Steam, Xbox, PC Game Pass |
| **Reconnection on IP Change** | Automatic via persistent hostname | Join code can change if server restarts |
| **Host System Overhead** | Minimal sidecar Docker container (~20 MB RAM) | Integrated into Valheim game process |
| **Best For** | Steam players wanting a permanent address & no port forwarding | Cross-platform friend groups (Xbox + PC) |

> [!TIP]
> You can keep both enabled simultaneously! Console players can use the Crossplay join code, while PC/Steam friends can join via Playit.

---

## 💾 Credentials & Resetting the Agent

* **Credential Location:** When claimed, credentials are stored in `config/playit/playit.toml`.
* **Git Safety:** `config/playit/` is included in [`.gitignore`](../.gitignore) to ensure private tokens are never committed to version control.
* **To Reset or Switch Accounts:**
  1. Stop containers: `docker compose down`
  2. Remove saved credentials:
     ```bash
     rm -rf config/playit/*
     ```
  3. Start the containers again (`docker compose up -d`) to receive a new claim URL.

---

## 🛠️ Troubleshooting

### 1. "I can't see the claim URL in the logs"
Run:
```bash
docker compose logs playit
```
If the container says `agent already registered` or `loaded credentials`, check `config/playit/playit.toml`. If you want to re-claim, delete `config/playit/playit.toml` and restart.

### 2. "Friends get 'Failed to connect' or timeout"
* **Check boot completion**: Valheim takes 2–4 minutes on first launch or during game updates. Check the `valheim-server` logs in Dozzle or run:
  ```bash
  docker compose logs -f valheim
  ```
  Ensure you see `Game server connected` before attempting connection.
* **Verify Tunnel Port**: Ensure your Playit dashboard tunnel is configured with:
  - Protocol: **UDP** (not TCP)
  - Local Address: `127.0.0.1`
  - Local Port: `2456`
* **Check Address Format**: In Valheim's Join IP dialog, make sure players paste the complete address including the colon and port number (e.g., `something.ply.gg:12345`).

---

## 📚 Related Guides
- [Quick Start & Operations Guide](getting-started.md)
- [How to Connect to Your Server](connecting.md)
- [Server Configuration & `docker-compose.yml`](configuration.md)
- [Monitoring Logs with Dozzle](dozzle.md)
- [Troubleshooting & Admin Guide](troubleshooting.md)
