# Автопереключение принтера на macOS

## Логика
Скрипт запускается каждые 3 минуты и определяет локацию по MAC-адресу роутера:
- MAC `6c:99:61:36:ae:a7` → **дом** → `EPSON_M1170_Series`
- Любой другой MAC → **офис** → `EPSON_WF_4745`

При переключении появляется уведомление. Если принтер уже правильный — ничего не происходит.

---

## Файлы пакета
- `printer_switch.sh` — основной скрипт
- `com.user.printer-switch.plist` — агент автозапуска (каждые 3 минуты)
- `install.sh` — установщик
- `INSTALL_README.md` — эта инструкция

---

## Шаг 1 — Узнай MAC домашнего роутера

Находясь **дома**, выполни в Terminal:
```bash
arp -n $(netstat -rn | grep default | grep en0 | awk '{print $2}' | head -1)
```
Вывод:
```
? (192.168.1.1) at 6c:99:61:36:ae:a7 on en0 ifscope [ethernet]
```
Значение после `at` — MAC роутера. Вставь его в `printer_switch.sh`:
```bash
HOME_GATEWAY_MAC="сюда_вставить_mac"
```

---

## Шаг 2 — Убедись что принтеры видны

```bash
lpstat -a
```
Должны быть `EPSON_M1170_Series` и `EPSON_WF_4745`.

---

## Шаг 3 — Установка

Положи все 4 файла в одну папку, затем:
```bash
cd ~/Downloads
chmod +x install.sh
./install.sh
```

---

## Проверка

```bash
# Текущий принтер
lpstat -d

# Последние записи лога
cat /tmp/printer_switch.log | tail -20

# Запустить вручную
bash /usr/local/bin/printer_switch.sh
```

---

## Просмотр логов
```bash
cat /tmp/printer_switch.log
cat /tmp/printer_switch.error.log
```

---

## Удаление
```bash
launchctl unload ~/Library/LaunchAgents/com.user.printer-switch.plist
rm ~/Library/LaunchAgents/com.user.printer-switch.plist
rm /usr/local/bin/printer_switch.sh
```
