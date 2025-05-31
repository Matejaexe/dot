#!/bin/bash

# Configuration - set your known devices here
KNOWN_DEVICES=(
    ["48"]="Built-in Audio"
    ["80"]="Redragon Gaming Headset"
)

# Get all available sinks
sinks=$(wpctl status | grep -A 10 "Sinks:" | tail -n +2 | grep -v "Sinks:" | sed '/^$/d' | awk '{print $1, substr($0, index($0,$3))}')

# Get current default sink
current_sink=$(wpctl inspect @DEFAULT_AUDIO_SINK@ | grep -E "node.id|node.description" | awk -F'"' '/node.id/{id=$2} /node.description/{desc=$2} END{print id, desc}')
current_id=${current_sink%% *}
current_name=${current_sink#* }

# Extract sink IDs and names
sink_ids=()
sink_names=()
while read -r id name; do
    sink_ids+=("$id")
    sink_names+=("$name")
done <<< "$sinks"

# Try to find next sink dynamically
next_index=0
for i in "${!sink_names[@]}"; do
    if [[ "${sink_names[$i]}" == "$current_name" ]] || [[ "${sink_ids[$i]}" == "$current_id" ]]; then
        next_index=$(( (i + 1) % ${#sink_names[@]} ))
        break
    fi
done

# Set the next sink
next_id="${sink_ids[$next_index]}"
next_name="${sink_names[$next_index]}"

# Verify against known devices
for id in "${!KNOWN_DEVICES[@]}"; do
    if [[ "$next_id" == "$id" ]] || [[ "$next_name" == "${KNOWN_DEVICES[$id]}" ]]; then
        wpctl set-default "$id"
        notify-send "Audio Switched" "Now using: ${KNOWN_DEVICES[$id]}" \
            -i "audio-$([[ "$id" == "80" ]] && echo "headphones" || echo "speakers")"
        exit 0
    fi
done

# Fallback to dynamic selection if no known device matched
wpctl set-default "$next_id"
notify-send "Audio Switched" "Now using: $next_name" -i audio-card
