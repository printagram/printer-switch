#!/bin/bash
# install.sh
# Installer for printer-switch: copies script and launchd agent, activates scheduling

set -e

SCRIPT_SRC="./printer_switch.sh"
SCRIPT_DST="/usr/local/bin/printer_switch.sh"
PLIST_SRC="./com.user.printer-switch.plist"
PLIST_DST="$HOME/Library/LaunchAgents/com.user.printer-switch.plist"
CONFIG_DIR="$HOME/.config/printer_switch"
CONFIG_FILE="$CONFIG_DIR/config"
AGENT_LABEL="com.user.printer-switch"

echo "=== Installing printer-switch ==="

# 1. Create config if it doesn't exist
if [ ! -f "$CONFIG_FILE" ]; then
    echo "→ Creating config at $CONFIG_FILE"
    mkdir -p "$CONFIG_DIR"
    cat > "$CONFIG_FILE" <<'CONF'
# Printer Switch Configuration
# Home router MAC address (lowercase, colon-separated)
HOME_GATEWAY_MAC="6c:99:61:36:ae:a7"
CONF
    echo "  OK — edit HOME_GATEWAY_MAC to match your router"
else
    echo "→ Config already exists at $CONFIG_FILE — skipping"
fi

# 2. Unload previous version of the agent
echo "→ Unloading old agent (if any)..."
launchctl bootout "gui/$(id -u)/$AGENT_LABEL" 2>/dev/null || true
echo "  OK"

# 3. Copy script
echo "→ Copying script to /usr/local/bin/"
sudo cp "$SCRIPT_SRC" "$SCRIPT_DST"
sudo chmod 755 "$SCRIPT_DST"
echo "  OK"

# 4. Copy plist
echo "→ Copying plist to ~/Library/LaunchAgents/"
cp "$PLIST_SRC" "$PLIST_DST"
echo "  OK"

# 5. Load agent
echo "→ Activating launchd agent (runs every 3 minutes)..."
launchctl bootstrap "gui/$(id -u)" "$PLIST_DST"
echo "  OK"

# 6. Run immediately
echo "→ Running first check..."
bash "$SCRIPT_DST"
echo ""
echo "=== Done! ==="
echo "Current default printer:"
lpstat -d
