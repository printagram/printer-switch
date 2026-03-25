#!/bin/bash
# printer_switch.sh
# /usr/local/bin/printer_switch.sh
# Auto-switch default printer based on gateway router MAC address
# Home:   configured in ~/.config/printer_switch/config
# Office: any other MAC

CONFIG_FILE="$HOME/.config/printer_switch/config"
LOG="/tmp/printer_switch.log"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG"
}

log "--- Script started ---"

# Load config
if [ ! -f "$CONFIG_FILE" ]; then
    log "Config not found: $CONFIG_FILE — exiting"
    exit 0
fi
source "$CONFIG_FILE"

if [ -z "$HOME_GATEWAY_MAC" ]; then
    log "HOME_GATEWAY_MAC not set in config — exiting"
    exit 0
fi

GATEWAY_IP=$(route -n get default 2>/dev/null | awk '/gateway:/{print $2}')
log "Gateway IP: '$GATEWAY_IP'"

if [ -z "$GATEWAY_IP" ]; then
    log "Gateway IP not detected — network unavailable, exiting"
    exit 0
fi

GATEWAY_MAC=$(arp -n "$GATEWAY_IP" 2>/dev/null | awk '{print $4}')
log "Gateway MAC: '$GATEWAY_MAC'"

CURRENT_PRINTER=$(lpstat -d 2>/dev/null | awk '{print $NF}')
log "Current printer: '$CURRENT_PRINTER'"

# Validate MAC (not empty, not incomplete)
if [ -z "$GATEWAY_MAC" ] || [[ "$GATEWAY_MAC" == *"incomplete"* ]]; then
    log "MAC not detected or incomplete — network unavailable, exiting"
    exit 0
fi

if [ "$GATEWAY_MAC" = "$HOME_GATEWAY_MAC" ]; then
    TARGET_PRINTER=$(lpstat -a 2>/dev/null | grep -i "M1170" | awk '{print $1}' | head -1)
    log "Location: HOME → target printer: '$TARGET_PRINTER'"
else
    TARGET_PRINTER=$(lpstat -a 2>/dev/null | grep -i "WF" | awk '{print $1}' | head -1)
    log "Location: OFFICE → target printer: '$TARGET_PRINTER'"
fi

if [ -z "$TARGET_PRINTER" ]; then
    log "Target printer not found in lpstat — exiting"
    exit 0
fi

if [ "$TARGET_PRINTER" = "$CURRENT_PRINTER" ]; then
    log "Printer already set to '$TARGET_PRINTER' — no change needed"
    exit 0
fi

log "Switching: '$CURRENT_PRINTER' → '$TARGET_PRINTER'"
lpoptions -d "$TARGET_PRINTER"
log "lpoptions executed"

osascript -e "display notification \"Printer: $TARGET_PRINTER\" with title \"Printer Switched\""
log "Notification sent"
log "--- Done ---"
