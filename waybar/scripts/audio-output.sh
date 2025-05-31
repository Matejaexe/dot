#!/bin/bash

# Check if audio system is responsive
if ! timeout 0.5s wpctl status >/dev/null 2>&1; then
    echo '{"text":" Audio Offline","class":"critical"}'
    exit 0
fi

# Get volume and mute status
volume_info=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ 2>/dev/null)
volume=$(awk '{printf "%d%%", $2*100}' <<< "$volume_info")
[[ "$volume_info" == *MUTED* ]] && muted=" (Muted)" || muted=""

# Get device name safely
device=$(timeout 0.5s wpctl inspect @DEFAULT_AUDIO_SINK@ 2>/dev/null | \
         awk -F'"' '/node.description/{print $2; exit}' || echo "Unknown Device")

# Set icon
case "$device" in
    *Headphone*|*Headset*) icon="";;
    *HDMI*)               icon="";;
    *Bluetooth*)          icon="";;
    *)                    icon="";;
esac

echo "{\"text\":\"$icon $volume$muted\", \"tooltip\":\"$device$muted\"}"
