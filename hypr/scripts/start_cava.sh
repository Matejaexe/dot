#!/bin/bash
sleep 3  # Wait for Deezer to start
hyprctl dispatch workspace 4
kitty --title cava -e cava &
