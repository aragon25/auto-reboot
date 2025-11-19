# auto-reboot

A Bash script and systemd service that automatically reboots the system based on configurable conditions such as uptime, free disk space, or OverlayFS status.

## 📌 Features

- **Automatic reboot** after a configurable uptime
- **Reboot when disk space is low** in OverlayFS
- Supports **hard reset** logic
- Easy activation/deactivation via CLI
- Integration with `systemd` as a service
- Configuration file for persistent settings

---

## 📂 Installation

### Option 1: Install via .deb package

The latest `.deb` installer can be found in the repository’s **Releases** section.

1. Download the latest release package:
   ```bash
   wget https://github.com/aragon25/auto-reboot/releases/download/v1.5-1/auto-reboot_1.5-1_all.deb
   ```

2. Install the package:
   ```bash
   sudo apt install ./auto-reboot_1.5-1_all.deb
   ```

This will:
- Place the script in `/usr/bin/`
- Install the systemd unit file
- Enable and start the service

---

### Option 2: Install from source

1. Clone the repository:
   ```bash
   git clone https://github.com/aragon25/auto-reboot.git
   cd auto-reboot
   ```

2. Copy the script:
   ```bash
   sudo cp ./src/auto-reboot.sh /usr/bin/auto-reboot
   sudo chmod +x /usr/bin/auto-reboot
   ```

3. Install the systemd service file:
   ```bash
   sudo cp ./src/auto-reboot.service /etc/systemd/system/auto-reboot.service
   ```

4. Enable the service:
   ```bash
   sudo systemctl daemon-reload
   sudo systemctl enable auto-reboot.service
   ```

---

## ⚙️ Configuration

The configuration is stored in  
`/etc/auto-reboot.config`.

| Key                              | Description                                           | Default |
|----------------------------------|-------------------------------------------------------|---------|
| `REBOOT_AFTER_HARD_RESET`        | `y` or `n` – Reboot after hard reset                  | `n`     |
| `OVERLAYFS_UPTIME_LIMIT_SECONDS` | Uptime limit (seconds) in OverlayFS mode              | `0`     |
| `OVERLAYFS_DISKFREE_LIMIT_BYTE`  | Minimum free disk space (bytes) in OverlayFS mode     | `0`     |
| `NORMAL_UPTIME_LIMIT_SECONDS`    | Uptime limit (seconds) in normal mode                 | `0`     |

---

## 🚀 Usage

```bash
auto-reboot [OPTION]
```

### Options

| Option                 | Description |
|------------------------|-------------|
| `--HARDRESET=y/n`      | Set reboot after hard reset |
| `--OFSUPTIME=<sec>`    | Uptime limit in OverlayFS mode |
| `--OFSDISKFREE=<byte>` | Minimum free disk space in OverlayFS |
| `--NRMUPTIME=<sec>`    | Uptime limit in normal mode |
| `-a`, `--activate`     | Activate and start service |
| `-d`, `--deactivate`   | Stop and deactivate service |
| `--boot`               | Execute boot logic |
| `--shutdown`           | Execute shutdown logic |
| `--service`            | Run in main service mode |
| `-v`, `--version`      | Show version info |
| `-h`, `--help`         | Show help message |

> ⚠️ **Note:**  
> Only one main option is allowed at a time (settings excluded).

---

## 📜 Examples

**Activate the service**:
```bash
sudo auto-reboot -a
```

**Reboot after 10 hours uptime in normal mode**:
```bash
sudo auto-reboot --NRMUPTIME=36000
```

**Reboot if less than 50 MB free in OverlayFS**:
```bash
sudo auto-reboot --OFSDISKFREE=52428800
```
