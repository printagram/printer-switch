# Printer Switch

Automatic default printer switching for macOS based on network location.

The script runs every 3 minutes via `launchd`, detects the current network by checking the gateway router's MAC address, and sets the appropriate default printer. A macOS notification appears when the printer changes.

## How it works

- **Home** (gateway MAC from config) → selects printer matching `M1170` (Epson M1170 Series)
- **Office** (any other gateway) → selects printer matching `WF` (Epson WorkForce WF-4745)
- If the correct printer is already set — nothing happens
- If the network is unavailable — the script exits silently

Printer names are resolved dynamically via `lpstat` + `grep`, so minor naming variations are handled automatically.

## Files

| File | Description |
|------|-------------|
| `printer_switch.sh` | Main script — detects location, switches printer |
| `com.user.printer-switch.plist` | launchd agent — runs the script every 3 minutes |
| `install.sh` | One-step installer |
| `uninstall.sh` | One-step uninstaller |

## Quick install

```bash
git clone git@github.com:YOUR_USERNAME/printer-switch.git
cd printer-switch
chmod +x install.sh
./install.sh
```

## Configuration

After installing, edit the config file with your home router's MAC address:

```bash
nano ~/.config/printer_switch/config
```

```bash
HOME_GATEWAY_MAC="your:mac:address:here"
```

To find your home router's MAC, run this while connected to your home Wi-Fi:

```bash
arp -n $(route -n get default | awk '/gateway:/{print $2}')
```

## Logs

```bash
cat /tmp/printer_switch.log        # script activity
cat /tmp/printer_switch.error.log  # errors
```

## Uninstall

```bash
./uninstall.sh
```

## Requirements

- macOS 10.15+
- Printers configured in System Settings → Printers & Scanners
- Wi-Fi connection via `en0`

## License

MIT
