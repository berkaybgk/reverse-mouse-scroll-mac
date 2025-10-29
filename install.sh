#!/bin/bash
set -e

# Define paths
REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
APP_NAME="ReverseMWheel.app"
APP_DEST="/Applications/$APP_NAME"
AGENT_PLIST="$HOME/Library/LaunchAgents/com.reversemouse.autorun.plist"
CONFIG_FILE="$HOME/.config/reverse_wheel/config"

echo "Installing ReverseMWheel automation..."

# Prompt for mouse brand
echo ""
echo "Enter your mouse brand (e.g., Razer, Logitech, Microsoft):"
read MOUSE_BRAND

# Validate input
if [ -z "$MOUSE_BRAND" ]; then
    echo "Error: Mouse brand cannot be empty"
    exit 1
fi

echo "Will monitor for: $MOUSE_BRAND"

# Copy app to Applications
if [ ! -d "$APP_DEST" ]; then
    echo "Copying app to /Applications..."
    cp -R "$REPO_DIR/$APP_NAME" "$APP_DEST"
fi

# Copy script to a user bin folder
mkdir -p "$HOME/.local/bin"
cp "$REPO_DIR/reverse_wheel.sh" "$HOME/.local/bin/reverse_wheel.sh"
chmod +x "$HOME/.local/bin/reverse_wheel.sh"

# Save configuration
mkdir -p "$HOME/.config/reverse_wheel"
echo "MOUSE_BRAND=$MOUSE_BRAND" > "$CONFIG_FILE"
echo "Configuration saved to: $CONFIG_FILE"

# Create LaunchAgent plist
cat > "$AGENT_PLIST" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" \
"http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key> <string>com.reversemouse.autorun</string>
    <key>ProgramArguments</key>
    <array>
        <string>$HOME/.local/bin/reverse_wheel.sh</string>
    </array>
    <key>RunAtLoad</key> <true/>
    <key>KeepAlive</key> <true/>
    <key>StandardOutPath</key>
    <string>$HOME/Library/Logs/reverse_mwheel.stdout.log</string>
    <key>StandardErrorPath</key>
    <string>$HOME/Library/Logs/reverse_mwheel.stderr.log</string>
</dict>
</plist>
EOF

# Load LaunchAgent
launchctl unload "$AGENT_PLIST" 2>/dev/null || true
launchctl load "$AGENT_PLIST"

echo ""
echo "✓ Installed successfully!"
echo "✓ The automation will now run automatically on mouse plug/unplug."
echo ""
echo "To change mouse brand later, edit: $CONFIG_FILE"
echo "Then restart with: launchctl unload '$AGENT_PLIST' && launchctl load '$AGENT_PLIST'"
