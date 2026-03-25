# Printer Switch

macOS utility that auto-switches the default printer based on network location.

## Architecture

Single bash script (`printer_switch.sh`) executed every 3 minutes by a launchd agent.

Detection method: gateway router MAC address via `arp`.
- Home MAC `6c:99:61:36:ae:a7` → grep for `M1170` in `lpstat -a`
- Any other MAC → grep for `WF` in `lpstat -a`

## Key design decisions

- Uses MAC address (not Wi-Fi SSID) for location detection — more reliable, works with hidden networks
- Gateway IP obtained via `route -n get default` (more reliable than netstat parsing)
- MAC address validated against `(incomplete)` ARP responses (e.g. after wake from sleep)
- Printer names resolved dynamically via `grep -i` on `lpstat` output — tolerant to name changes
- Only switches if the current default differs from target — no unnecessary writes
- Logs all actions to `/tmp/printer_switch.log` with timestamps
- Config stored externally in `~/.config/printer_switch/config` — no secrets in the repo

## Files

- `printer_switch.sh` — main script, installed to `/usr/local/bin/`
- `com.user.printer-switch.plist` — launchd agent, installed to `~/Library/LaunchAgents/`
- `install.sh` — automated installer (copies files, creates config, loads agent)
- `uninstall.sh` — automated uninstaller (stops agent, removes installed files)

## Environment

- macOS, Wi-Fi interface `en0`
- Home printer: Epson M1170 Series (network printer)
- Office printer: Epson WorkForce WF-4745 (network printer)
- Owner uses Russian as primary language; code comments are in English

## Conventions

- Log format: `[YYYY-MM-DD HH:MM:SS] message`
- Exit code 0 in all cases (non-critical utility)
- No external dependencies beyond standard macOS tools (bash, arp, route, lpstat, lpoptions, osascript)
