#!/usr/bin/env bash
# Network status for mangobar custom/network module.
# Outputs:  "󰤨 MySSID"  |  "󰈀"  |  "󰖩"

# Find the interface holding the default route
iface=$(ip route show default 2>/dev/null | awk '{for(i=1;i<=NF;i++) if($i=="dev"){print $(i+1); exit}}')

# If no default route, check for any UP non-loopback interfaces
if [ -z "$iface" ]; then
    iface=$(ip -o link show up 2>/dev/null | awk -F': ' '$2 != "lo" {print $2; exit}')
fi

# No interfaces found at all — just show the wifi icon
if [ -z "$iface" ]; then
    echo "󰖩"
    exit 0
fi

# Determine connection type
if [ -d "/sys/class/net/${iface}/wireless" ] || iw dev "$iface" link &>/dev/null; then
    # WiFi
    ssid=$(iwgetid -r 2>/dev/null || iw dev "$iface" link 2>/dev/null | awk '/SSID/{print $2}')
    if [ -n "$ssid" ]; then
        # Get signal strength
        signal=$(iw dev "$iface" link 2>/dev/null | awk '/signal:/{print $2}')
        signal=${signal%%.*}  # strip decimal
        if   [ "${signal:-0}" -ge 80 ] 2>/dev/null; then icon="󰤨"
        elif [ "${signal:-0}" -ge 60 ] 2>/dev/null; then icon="󰤥"
        elif [ "${signal:-0}" -ge 40 ] 2>/dev/null; then icon="󰤢"
        elif [ "${signal:-0}" -ge 20 ] 2>/dev/null; then icon="󰤟"
        else icon="󰤯"
        fi
        echo "$icon $ssid"
    else
        echo "󰖩"
    fi
else
    # Wired
    echo "󰈀"
fi
