# Reverse Mouse Wheel (macOS Automation)

A lightweight macOS automation that **reverses the scroll direction** when an **external mouse** is connected — and automatically switches back when it's disconnected.

This project uses a small **Automator app** and a **background shell script** that watches for mouse plug/unplug events.  
It's ideal for users who prefer *natural scrolling* on their trackpad but *traditional scrolling* on an external mouse.

---

## Features

- Automatically toggles **"Natural Scrolling"** when a mouse is plugged or unplugged  
- Runs automatically in the background using **LaunchAgent**  
- Works with both **USB** and **Bluetooth** mice  
- **Configurable** for any mouse brand (Razer, Logitech, Microsoft, etc.)
- Installs with one command — configuration included  

---

## Installation

Clone this repository and run the installer:

```bash
git clone https://github.com/berkaybgk/reverse-mouse-scroll-mac.git
cd reverse-mouse-scroll-mac
chmod +x install.sh
./install.sh
```

During installation, you'll be prompted to enter your **mouse brand** (e.g., `Razer`, `Logitech`, `Microsoft`). This helps the script identify your specific mouse when it connects or disconnects.

The installer will:
1. Copy the Automator app to `/Applications`
2. Install the monitoring script to `~/.local/bin`
3. Save your mouse brand configuration
4. Set up a LaunchAgent to run automatically in the background

---

## Configuration

### Changing Your Mouse Brand

If you need to change the mouse brand later, you can either:

**Option 1: Edit the config file directly**
```bash
nano ~/.config/reverse_wheel/config
```

Then restart the service:
```bash
launchctl unload ~/Library/LaunchAgents/com.reversemouse.autorun.plist
launchctl load ~/Library/LaunchAgents/com.reversemouse.autorun.plist
```

**Option 2: Re-run the installer**
```bash
./install.sh
```

### Checking Logs

To verify the automation is working or troubleshoot issues:

```bash
# View event log
tail -f ~/Library/Logs/reverse_mwheel.log

# View standard output
tail -f ~/Library/Logs/reverse_mwheel.stdout.log

# View errors
tail -f ~/Library/Logs/reverse_mwheel.stderr.log
```

---

## Uninstallation

To remove the automation:

```bash
# Unload the LaunchAgent
launchctl unload ~/Library/LaunchAgents/com.reversemouse.autorun.plist

# Remove files
rm ~/Library/LaunchAgents/com.reversemouse.autorun.plist
rm ~/.local/bin/reverse_wheel.sh
rm -rf ~/.config/reverse_wheel
rm -rf /Applications/ReverseMWheel.app

# Optional: Remove logs
rm ~/Library/Logs/reverse_mwheel*.log
```

---

## How It Works

1. The `install.sh` script prompts for your mouse brand and saves it to a config file
2. A LaunchAgent runs `reverse_wheel.sh` automatically in the background
3. The script monitors USB and Bluetooth devices for your specific mouse
4. When your mouse connects/disconnects, it opens the Automator app to toggle scroll direction
5. The Automator app uses AppleScript to flip the "Natural Scrolling" setting in System Preferences

---

## Troubleshooting

**The automation isn't triggering:**
- Check if your mouse brand is correctly configured: `cat ~/.config/reverse_wheel/config`
- Verify the mouse name by running: `ioreg -p IOUSB -l | grep -i mouse` (for USB) or `ioreg -p IOBluetooth -l | grep -i mouse` (for Bluetooth)
- This automation has not been tested with different mouse brands so it might fail to detect yours. Above comment can be useful to debug the issue.
- Check the logs: `tail -f ~/Library/Logs/reverse_mwheel.log`

**The script triggers but scroll direction doesn't change:**
- Make sure `ReverseMWheel.app` is in `/Applications`
- Grant necessary permissions if macOS prompts for Accessibility access

**Want to monitor a different keyword:**
- The mouse brand can be any text that appears in your mouse's device name
- Use `ioreg` commands above to find the exact name, then update your config

---

## License

MIT License - Feel free to modify and distribute.

---

## Contributing

Pull requests are welcome! If you find a bug or have a feature request, please open an issue.
