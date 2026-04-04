#!/bin/bash
# printer_switch.sh
# /usr/local/bin/printer_switch.sh
# Автопереключение принтера и позиции Dock по MAC-адресу роутера
# Дом:  6c:99:61:36:ae:a7 → EPSON_M1170_Series + Dock справа
# Офис: любой другой MAC  → EPSON_WF_4745 + Dock слева

HOME_GATEWAY_MAC="6c:99:61:36:ae:a7"
LOG="/tmp/printer_switch.log"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG"
}

log "--- Скрипт запущен ---"

GATEWAY_IP=$(netstat -rn | grep default | grep en0 | awk '{print $2}' | head -1)
log "Gateway IP: '$GATEWAY_IP'"

GATEWAY_MAC=$(arp -n "$GATEWAY_IP" 2>/dev/null | awk '{print $4}')
log "Gateway MAC: '$GATEWAY_MAC'"

if [ -z "$GATEWAY_MAC" ]; then
    log "MAC не определён — сеть недоступна, выходим"
    exit 0
fi

# --- Принтер ---
CURRENT_PRINTER=$(lpstat -d 2>/dev/null | awk '{print $NF}')
log "Текущий принтер: '$CURRENT_PRINTER'"

if [ "$GATEWAY_MAC" = "$HOME_GATEWAY_MAC" ]; then
    TARGET_PRINTER=$(lpstat -a 2>/dev/null | grep -i "M1170" | awk '{print $1}' | head -1)
    TARGET_DOCK="left"
    LOCATION="ДОМ"
else
    TARGET_PRINTER=$(lpstat -a 2>/dev/null | grep -i "WF" | awk '{print $1}' | head -1)
    TARGET_DOCK="left"
    LOCATION="ОФИС"
fi

log "Локация: $LOCATION → принтер: '$TARGET_PRINTER', Dock: $TARGET_DOCK"

if [ -n "$TARGET_PRINTER" ] && [ "$TARGET_PRINTER" != "$CURRENT_PRINTER" ]; then
    lpoptions -d "$TARGET_PRINTER"
    log "Принтер переключён: '$CURRENT_PRINTER' → '$TARGET_PRINTER'"
else
    log "Принтер уже '$CURRENT_PRINTER' — менять не нужно"
fi

# --- Dock ---
CURRENT_DOCK=$(defaults read com.apple.dock orientation 2>/dev/null)
log "Текущий Dock: '$CURRENT_DOCK'"

if [ "$CURRENT_DOCK" != "$TARGET_DOCK" ]; then
    defaults write com.apple.dock orientation -string "$TARGET_DOCK"
    killall Dock
    log "Dock переключён: '$CURRENT_DOCK' → '$TARGET_DOCK'"
else
    log "Dock уже '$CURRENT_DOCK' — менять не нужно"
fi

# --- Уведомление ---
if [ "$TARGET_PRINTER" != "$CURRENT_PRINTER" ] || [ "$CURRENT_DOCK" != "$TARGET_DOCK" ]; then
    osascript -e "display notification \"Принтер: $TARGET_PRINTER | Dock: $TARGET_DOCK\" with title \"Переключено: $LOCATION\""
    log "Уведомление отправлено"
fi

log "--- Готово ---"
