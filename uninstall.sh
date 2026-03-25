#!/bin/bash
# uninstall.sh
# Uninstaller for printer-switch: stops agent, removes installed files

SCRIPT_DST="/usr/local/bin/printer_switch.sh"
PLIST_DST="$HOME/Library/LaunchAgents/com.user.printer-switch.plist"
AGENT_LABEL="com.user.printer-switch"

echo "=== Uninstalling printer-switch ==="

# 1. Unload agent
echo "→ Stopping launchd agent..."
launchctl bootout "gui/$(id -u)/$AGENT_LABEL" 2>/dev/null || true
echo "  OK"

# 2. Remove plist
if [ -f "$PLIST_DST" ]; then
    echo "→ Removing plist..."
    rm "$PLIST_DST"
    echo "  OK"
else
    echo "→ Plist not found — skipping"
fi

# 3. Remove script
if [ -f "$SCRIPT_DST" ]; then
    echo "→ Removing script from /usr/local/bin/..."
    sudo rm "$SCRIPT_DST"
    echo "  OK"
else
    echo "→ Script not found — skipping"
fi

echo ""
echo "=== Done! ==="
echo "Config preserved at ~/.config/printer_switch/config"
echo "To remove config: rm -rf ~/.config/printer_switch"
