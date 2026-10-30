#!/usr/bin/env bash
# Network status for mangobar custom/network module.
# Outputs signal-strength icon + SSID (wifi), ethernet icon, or disconnected icon.
# Exit codes: 0 = connected, 1 = disconnected

# Signal-strength icons: weakest → strongest (5-step ladder)
SIG_ICONS=("󰤯" "󰤟" "󰤢" "󰤥" "󰤨")

signal_icon() {
    local strength="${1:-0}"
    if   [ "$strength" -ge 80 ] 2>/dev/null; then echo "${SIG_ICONS[4]}"
    elif [ "$strength" -ge 60 ] 2>/dev/null; then echo "${SIG_ICONS[3]}"
    elif [ "$strength" -ge 40 ] 2>/dev/null; then echo "${SIG_ICONS[2]}"
    elif [ "$strength" -ge 20 ] 2>/dev/null; then echo "${SIG_ICONS[1]}"
    else echo "${SIG_ICONS[0]}"
    fi
}

# ── Try nmcli (NetworkManager) ─────────────────────────────────────────
if command -v nmcli &>/dev/null; then
    # Active connection line: TYPE:DEVICE:STATE
    line=$(nmcli -t -f TYPE,DEVICE,STATE dev status 2>/dev/null | grep ":connected$" | head -1)
    conn_type=$(echo "$line" | cut -d: -f1)

    if [ "$conn_type" = "wifi" ]; then
        ssid=$(nmcli -t -f active,ssid dev wifi 2>/dev/null | grep "^yes" | cut -d: -f2)
        signal=$(nmcli -t -f active,SIGNAL dev wifi 2>/dev/null | grep "^yes" | cut -d: -f2 | head -1)
        icon=$(signal_icon "$signal")
        echo "$icon"
        exit 0
    elif [ -n "$conn_type" ]; then
        echo "󰈀"
        exit 0
    fi
fi

# ── Fallback: /sys carrier check ───────────────────────────────────────
for iface in /sys/class/net/*; do
    [ "$(cat "$iface/carrier" 2>/dev/null)" = "1" ] || continue
    name=$(basename "$iface")
    [ "$name" = "lo" ] && continue
    if [ -d "$iface/wireless" ]; then
        echo "󰖩 $name"
    else
        echo "󰈀"
    fi
    exit 0
done

echo "󰖪"
exit 1
