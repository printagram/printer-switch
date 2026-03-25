#!/bin/bash
# install.sh
# Installer for printer-switch: copies script and launchd agent, activates scheduling

set -e

SCRIPT_SRC="./printer_switch.sh"
SCRIPT_DST="/usr/local/bin/printer_switch.sh"
PLIST_SRC="./com.user.printer-switch.plist"
PLIST_DST="$HOME/Library/LaunchAgents/com.user.printer-switch.plist"

echo "=== Installing printer-switch ==="

# 1. Unload previous version if present
echo "→ Unloading old agent (if any)..."
launchctl unload "$PLIST_DST" 2>/dev/null || true
echo "  OK"

# 2. Copy script
echo "→ Copying script to /usr/local/bin/"
sudo cp "$SCRIPT_SRC" "$SCRIPT_DST"
sudo chmod 755 "$SCRIPT_DST"
echo "  OK"

# 3. Copy plist
echo "→ Copying plist to ~/Library/LaunchAgents/"
cp "$PLIST_SRC" "$PLIST_DST"
echo "  OK"

# 4. Load agent
echo "→ Activating launchd agent (runs every 3 minutes)..."
launchctl load "$PLIST_DST"
echo "  OK"

# 5. Run immediately
echo "→ Running first check..."
bash "$SCRIPT_DST"
echo ""
echo "=== Done! ==="
echo "Current default printer:"
lpstat -d
