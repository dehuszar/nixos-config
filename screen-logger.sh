#!/usr/bin/env bash
while true; do
  tablet=$(cat /sys/devices/platform/thinkpad_acpi/hotkey_tablet_mode 2>/dev/null || echo "?")
  status=$(cat /sys/class/drm/card1-eDP-1/status 2>/dev/null || echo "?")
  enabled=$(cat /sys/class/drm/card1-eDP-1/enabled 2>/dev/null || echo "?")
  echo "$(date '+%H:%M:%S') tablet=$tablet edp_status=$status edp_enabled=$enabled"
  sleep 0.5
done
