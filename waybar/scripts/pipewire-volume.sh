#!/bin/bash

# Get volume and mute status
volume=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{print $2*100}')
is_muted=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | grep -q MUTED && echo "true" || echo "false")

# Check if using Bluetooth
is_bluetooth=$(wpctl inspect @DEFAULT_AUDIO_SINK@ | grep "device.api" | grep -q "bluez" && echo "true" || echo "false")

# Determine icon
if [ "$is_muted" = "true" ]; then
    icon=""  # Muted icon
elif [ "$is_bluetooth" = "true" ]; then
    case $(wpctl inspect @DEFAULT_AUDIO_SINK@ | grep "node.description" | cut -d'"' -f2) in
        *"Headset"*) icon="";;
        *"Headphone"*) icon="";;
        *) icon="";;  # Generic Bluetooth icon
    esac
else
    # Volume level icons
    if [ "${volume%.*}" -lt 30 ]; then
        icon=""
    elif [ "${volume%.*}" -lt 70 ]; then
        icon=""
    else
        icon=""
    fi
fi

# Output JSON for Waybar
echo "{\"text\":\"$icon ${volume%.*}%\", \"alt\":\"$is_muted\", \"tooltip\":\"Volume: ${volume%.*}%\"}"
