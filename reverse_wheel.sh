#!/bin/bash

APP_PATH="/Applications/ReverseMWheel.app"
EVENT_LOG="$HOME/Library/Logs/reverse_mwheel.log"
CONFIG_FILE="$HOME/.config/reverse_wheel/config"

# Load mouse brand from config file
if [ ! -f "$CONFIG_FILE" ]; then
    echo "$(date): Error - Configuration file not found: $CONFIG_FILE" >> "$EVENT_LOG"
    echo "Error: Configuration file not found. Please run install.sh first."
    exit 1
fi

# Source the config file to load MOUSE_BRAND
source "$CONFIG_FILE"

# Validate that MOUSE_BRAND was loaded
if [ -z "$MOUSE_BRAND" ]; then
    echo "$(date): Error - MOUSE_BRAND not set in config" >> "$EVENT_LOG"
    echo "Error: Mouse brand not configured. Please run install.sh again."
    exit 1
fi

echo "$(date): Loaded configuration - monitoring for: $MOUSE_BRAND" >> "$EVENT_LOG"

# Function to check if the specified mouse is connected
is_mouse_connected() {
    # Look for external USB or Bluetooth pointing devices
    if ioreg -p IOUSB -l | grep -iq "$MOUSE_BRAND"; then
        return 0  # Mouse IS connected (0 = true in bash)
    fi
    if ioreg -p IOBluetooth -l | grep -iq "$MOUSE_BRAND"; then
        return 0  # Mouse IS connected via Bluetooth
    fi
    return 1  # Mouse is NOT connected
}

# Get initial mouse state and set PREV_STATE accordingly
if is_mouse_connected; then
    PREV_STATE="connected"
    echo "$(date): Initial state - Mouse IS connected" >> "$EVENT_LOG"
else
    PREV_STATE="disconnected"
    echo "$(date): Initial state - Mouse NOT connected" >> "$EVENT_LOG"
fi

echo "$(date): Starting ReverseMWheel watcher for $MOUSE_BRAND" >> "$EVENT_LOG"

# Main monitoring loop
while true; do
    if is_mouse_connected; then
        if [ "$PREV_STATE" != "connected" ]; then
            echo "$(date): $MOUSE_BRAND mouse connected, reversing scroll direction..." >> "$EVENT_LOG"
            open "$APP_PATH"
            PREV_STATE="connected"
        fi
    else
        if [ "$PREV_STATE" != "disconnected" ]; then
            echo "$(date): $MOUSE_BRAND mouse disconnected, reverting scroll direction..." >> "$EVENT_LOG"
            open "$APP_PATH"
            PREV_STATE="disconnected"
        fi
    fi
    sleep 5
done
