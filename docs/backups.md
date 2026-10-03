# 💾 Backing Up & Restoring Your Valheim World

Nothing is worse than losing dozens or hundreds of hours of Viking building! This guide explains how automatic backups work, how to create manual snapshots, and how to restore your world in case of corruption or accidental destruction.

---

## 🤖 1. Built-in Automatic Backups

The server image (`ghcr.io/community-valheim-tools/valheim-server`) comes with an **automated backup utility** enabled by default.

* **Backup Location**:
  ```text
  config/backups/
  ```
* **How it works**:
  - The server periodically compresses your active world save files into timestamped `.zip` archives.
  - Backups are stored in your local [`config/backups`](../config) folder on your host machine.
  - Because [`config`](../config) is a mapped Docker volume, your backups survive container restarts, upgrades, and system reboots.

### Backup Configuration Options

You can customize backup schedules and retention in [`.env`](../.env) or [`docker-compose.yml`](../docker-compose.yml):

| Variable | Default | Purpose |
| :--- | :--- | :--- |
| `BACKUPS` | `true` | Enables or disables periodic automated backups. |
| `BACKUPS_MAX_AGE` | `3` | **Retention period in days.** Backups older than this number of days are automatically deleted. Increase this (e.g. `30` or `90`) to retain backups longer. |
| `BACKUPS_MAX_COUNT` | `0` | Maximum number of backup files to keep (`0` means unlimited, constrained only by age). |
| `BACKUPS_CRON` | `5 * * * *` | Cron schedule for taking backups (default: hourly at minute 5). |
| `BACKUPS_IF_IDLE` | `true` | When `false`, pauses backup creation when no players are connected to save disk space. |
| `BACKUPS_IDLE_GRACE_PERIOD` | `3600` | Grace period in seconds to keep taking backups after the last player disconnects. |

---

## 📦 2. Creating a Manual Backup (Snapshot)

Always take a manual snapshot before upgrading server images, running game updates, or experimenting with mods.

### Step-by-Step Manual Backup:
1. **Stop the server safely**:
   ```bash
   docker compose down
   ```
   *(Stopping the server flushes any in-memory world data to disk so the files aren't mid-write).*

2. **Copy the `config/` directory**:
   - In Finder (macOS) or File Explorer (Windows), copy the entire [`config/`](../config) folder.
   - Paste it in a safe backup location (e.g., `~/Desktop/valheim_backup_2026-10-02/` or cloud storage like Google Drive / Dropbox).

3. **Restart the server**:
   ```bash
   docker compose up -d
   ```

---

## 📂 3. Where World Saves Live

Active world files are located at:
```text
config/worlds_local/
```

Every Valheim world consists of two critical files named after your `WORLD_NAME` setting (default: `Dedicated`):
1. **`<WORLD_NAME>.db`**: Contains the world terrain modifications, building structures, containers, and placed objects.
2. **`<WORLD_NAME>.fwl`**: Contains the world seed, creation metadata, and world flags.

> [!IMPORTANT]  
> Both the `.db` and `.fwl` files are required. If either file is missing or mismatched, the game cannot load the world properly.

---

## 🔄 4. How to Restore an Old Save

If a world becomes corrupted or a base was destroyed by trolls:

1. **Stop the server**:
   ```bash
   docker compose down
   ```

2. **Locate your backup files**:
   - From an automatic backup in `config/backups/`, unzip the desired archive.
   - Or from your manual backup folder.

3. **Replace the active files**:
   - Copy the backup `.db` and `.fwl` files into:
     ```text
     config/worlds_local/
     ```
   - Ensure the filenames match your `WORLD_NAME` setting (e.g. `Dedicated.db` and `Dedicated.fwl`).

4. **Restart the server**:
   ```bash
   docker compose up -d
   ```

5. **Verify in logs**:
   ```bash
   docker compose logs -f
   ```
   *(or check [Dozzle](dozzle.md) in your browser)* to verify that the world loaded without errors.

---

## 📚 Related Guides
- [Quick Start & Operations Guide](getting-started.md)
- [Playit.gg Zero-Port-Forwarding Tunnel](playit.md)
- [Server Configuration & `docker-compose.yml`](configuration.md)
- [How to Connect to Your Server](connecting.md)
- [Monitoring Logs with Dozzle](dozzle.md)
- [Troubleshooting & Admin Guide](troubleshooting.md)
