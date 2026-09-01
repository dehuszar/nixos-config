# Troubleshooting App Launch Issues

## ✅ What Was Fixed

1. **Process Detachment**: Changed from direct execution to shell background execution (`sh -c "app &"`)
2. **Proper Lifecycle**: Using `running = true/false` instead of `.run()`
3. **Better Logging**: Added console output to debug what's happening
4. **Timer Reset**: Auto-stops processes after 2 seconds to prevent hanging

## 🐛 Current Issues

### Impala complains "iwd is not activateable"

This is an **impala/iwd configuration issue**, not a Quickshell problem.

**What it means:**
- Impala (network manager) tries to use `iwd` (iNet Wireless Daemon)
- `iwd` service is not running or not configured on your system

**Solutions:**

#### Option 1: Start iwd service
```bash
# Check if iwd is installed
which iwd

# Start iwd service
sudo systemctl start iwd
sudo systemctl enable iwd  # Auto-start on boot
```

#### Option 2: Use NetworkManager instead
If you're using NetworkManager, configure impala to use it:
```bash
# Check NetworkManager status
systemctl status NetworkManager

# Configure impala to use NetworkManager (check impala docs)
```

#### Option 3: Change to a different network tool
Edit `bar/Bar.qml` and change the command:
```qml
Process {
    id: launchImpala
    // Instead of impala, use:
    command: ["sh", "-c", "nm-connection-editor &"]  // NetworkManager GUI
    // or
    command: ["sh", "-c", "nmtui &"]  // NetworkManager TUI
}
```

### Ghostty/Wiremix Not Launching

**Check 1: Are they installed?**
```bash
which ghostty
which wiremix
```

**Check 2: Do they work from terminal?**
```bash
ghostty &
wiremix &
```

**Check 3: Check Quickshell console output**
When you click the icon, you should see:
```
=== Launching Ghostty ===
Command: sh,-c,ghostty &
```

If you don't see this, the click isn't registering.

**Check 4: Look for errors**
After clicking, check if there are error messages in the terminal where you ran quickshell.

## 🔧 How to Debug

### Enable Verbose Logging

The bar now logs every launch attempt. Watch the terminal output when you click:

```bash
# Run quickshell and watch for logs
quickshell -p ~/nixos-config/modules/home/quickshell-configs/kartik317
```

Expected output when clicking:
```
=== Launching Wiremix ===
Command: sh,-c,wiremix &
```

### Test Commands Manually

Copy the command from the log and test it:
```bash
sh -c "wiremix &"
```

### Check Process Status

After clicking, check if the process started:
```bash
ps aux | grep wiremix
ps aux | grep ghostty
ps aux | grep impala
```

## 💡 Alternative Launch Methods

If the current method doesn't work, try these alternatives:

### Method 1: Direct Execution (Original)
```qml
Process {
    id: launchApp
    command: ["wiremix"]
}

// In MouseArea:
onClicked: launchApp.running = true
```

### Method 2: Shell Background (Current)
```qml
Process {
    id: launchApp
    command: ["sh", "-c", "wiremix &"]
}

// In MouseArea:
onClicked: {
    launchApp.running = true
    resetTimer.restart()
}
```

### Method 3: Desktop File Launcher
```qml
Process {
    id: launchApp
    command: ["gtk-launch", "wiremix.desktop"]
}
```

### Method 4: xdg-open (for URLs/files)
```qml
import Qt.labs.platform

MouseArea {
    onClicked: {
        Qt.openUrlExternally("file:///usr/bin/wiremix")
    }
}
```

## 🎯 Recommended Fixes

### For Impala/iwd Issue

**Quick Fix:** Change to NetworkManager tool
```qml
// In bar/Bar.qml, find launchImpala and change:
Process {
    id: launchImpala
    command: ["sh", "-c", "nmtui &"]  // Terminal-based NetworkManager
}
```

**Better Fix:** Install and configure iwd
```bash
sudo nix-env -iA iwd  # Or install via your package manager
sudo systemctl enable --now iwd
```

### For Other Apps

If apps still don't launch, try removing the `&`:
```qml
Process {
    id: launchWiremix
    command: ["sh", "-c", "wiremix"]  // No &
}
```

Or use absolute paths:
```qml
Process {
    id: launchWiremix
    command: ["sh", "-c", "/run/current-system/sw/bin/wiremix &"]
}
```

## 📝 Testing Checklist

- [ ] Apps launch from terminal manually
- [ ] Console shows "=== Launching ===" message when clicking
- [ ] No error messages in quickshell terminal
- [ ] Process appears in `ps aux` after clicking
- [ ] App window actually opens

## 🚀 Next Steps

1. **Test wiremix and ghostty** - These should work now
2. **Fix impala** - Either start iwd or change to nmtui
3. **Add more apps** - Follow the same pattern for other icons
4. **Report back** - Let me know what works and what doesn't!

---

## Quick Reference: Working Commands

Test these in your terminal first:

```bash
# Should open terminal
ghostty &

# Should open audio control  
wiremix &

# Will fail without iwd
impala &

# Alternative network tools
nmtui &                    # Terminal UI
nm-connection-editor &     # GUI (if installed)
nmcli &                    # Command-line
```

Once you confirm which commands work, update the Process declarations in `bar/Bar.qml` accordingly!
