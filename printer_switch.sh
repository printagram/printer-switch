#!/bin/bash
# printer_switch.sh
# /usr/local/bin/printer_switch.sh
# Auto-switch default printer based on gateway router MAC address
# Home:   6c:99:61:36:ae:a7 → EPSON_M1170_Series
# Office: any other MAC      → EPSON_WF_4745

HOME_GATEWAY_MAC="6c:99:61:36:ae:a7"
LOG="/tmp/printer_switch.log"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG"
}

log "--- Script started ---"

GATEWAY_IP=$(netstat -rn | grep default | grep en0 | awk '{print $2}' | head -1)
log "Gateway IP: '$GATEWAY_IP'"

GATEWAY_MAC=$(arp -n "$GATEWAY_IP" 2>/dev/null | awk '{print $4}')
log "Gateway MAC: '$GATEWAY_MAC'"

CURRENT_PRINTER=$(lpstat -d 2>/dev/null | awk '{print $NF}')
log "Current printer: '$CURRENT_PRINTER'"

if [ -z "$GATEWAY_MAC" ]; then
    log "MAC not detected — network unavailable, exiting"
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
