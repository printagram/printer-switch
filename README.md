# Printer Switch

Automatic default printer switching for macOS based on network location.

The script runs every 3 minutes via `launchd`, detects the current network by checking the gateway router's MAC address, and sets the appropriate default printer. A macOS notification appears when the printer changes.

## How it works

- **Home** (gateway MAC `6c:99:61:36:ae:a7`) → selects printer matching `M1170` (Epson M1170 Series)
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
| `INSTALL_README.md` | Detailed installation instructions (in Russian) |

## Quick install

```bash
git clone git@github.com:YOUR_USERNAME/printer-switch.git
cd printer-switch
chmod +x install.sh
./install.sh
```

## Configuration

Before installing, edit `printer_switch.sh` and set your home router's MAC address:

```bash
HOME_GATEWAY_MAC="your:mac:address:here"
```

To find your home router's MAC, run this while connected to your home Wi-Fi:

```bash
arp -n $(netstat -rn | grep default | grep en0 | awk '{print $2}' | head -1)
```

## Logs

```bash
cat /tmp/printer_switch.log        # script activity
cat /tmp/printer_switch.error.log  # errors
```

## Uninstall

```bash
launchctl unload ~/Library/LaunchAgents/com.user.printer-switch.plist
rm ~/Library/LaunchAgents/com.user.printer-switch.plist
sudo rm /usr/local/bin/printer_switch.sh
```

## Requirements

- macOS 10.15+
- Printers configured in System Settings → Printers & Scanners
- Wi-Fi connection via `en0`

## License

MIT
