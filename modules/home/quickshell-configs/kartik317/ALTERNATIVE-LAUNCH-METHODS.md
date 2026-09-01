# Alternative App Launch Methods

If `nohup` doesn't work, try these alternatives in order:

## Method 1: systemd-run (Recommended for NixOS)

```qml
Process {
    id: launchWiremix
    command: ["systemd-run", "--user", "--pipe", "wiremix"]
}
```

## Method 2: Double fork via shell

```qml
Process {
    id: launchWiremix
    command: ["sh", "-c", "wiremix > /dev/null 2>&1 & disown"]
}
```

## Method 3: Write a launcher script

Create `~/bin/launch-wiremix.sh`:
```bash
#!/usr/bin/env bash
wiremix &
disown
exit 0
```

Make it executable:
```bash
chmod +x ~/bin/launch-wiremix.sh
```

Then use:
```qml
Process {
    id: launchWiremix
    command: ["/home/sam/bin/launch-wiremix.sh"]
}
```

## Method 4: Use Qt.labs.platform (if available)

```qml
import Qt.labs.platform

// In MouseArea onClicked:
onClicked: {
    Qt.openUrlExternally("file:///run/current-system/sw/bin/wiremix")
}
```

## Debugging Steps

1. **Test nohup manually:**
   ```bash
   nohup wiremix &
   # Check if it launched
   ps aux | grep wiremix
   ```

2. **Check Quickshell logs:**
   Look for error messages when clicking

3. **Verify app paths:**
   ```bash
   which wiremix
   which ghostty
   which impala
   ```

4. **Try absolute paths:**
   ```qml
   Process {
       id: launchWiremix
       command: ["nohup", "/run/current-system/sw/bin/wiremix"]
   }
   ```

## Current Implementation

Using: `["nohup", "app-name"]`

If this doesn't work, report back and we'll try Method 1 (systemd-run) which is more reliable on NixOS/systemd systems.
