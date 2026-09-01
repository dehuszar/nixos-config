# Quick Start: Testing Your New Quickshell Configs

## 🚀 Get Started in 5 Minutes

### Step 1: Test the Minimal Config
```bash
# Inside your VM, run:
quickshell -p ~/nixos-config/modules/home/quickshell-configs/minimal
```

You should see a simple bar at the top with:
- "WS: 1" on the left
- Current time on the right

### Step 2: Switch to a Different Config
Edit `~/nixos-config/modules/home/quickshell.nix`:
```nix
activeExample = "catppuccin";  # Change from "minimal" to "catppuccin"
```

Rebuild:
```bash
make vm-build
make vm-run
```

Or test directly:
```bash
quickshell -p ~/nixos-config/modules/home/quickshell-configs/catppuccin
```

### Step 3: Explore All Options

Try each config to see what you like:

```bash
# Learning path (simplest to most complex)
quickshell -p ~/nixos-config/modules/home/quickshell-configs/minimal
quickshell -p ~/nixos-config/modules/home/quickshell-configs/basic
quickshell -p ~/nixos-config/modules/home/quickshell-configs/intermediate
quickshell -p ~/nixos-config/modules/home/quickshell-configs/maximal

# Themed variations
quickshell -p ~/nixos-config/modules/home/quickshell-configs/catppuccin
quickshell -p ~/nixos-config/modules/home/quickshell-configs/macos
quickshell -p ~/nixos-config/modules/home/quickshell-configs/windows11
quickshell -p ~/nixos-config/modules/home/quickshell-configs/gnome
```

---

## 📋 Available Configs Quick Reference

| Name | Style | Position | Complexity | Best For |
|------|-------|----------|------------|----------|
| **minimal** | Simple | Top | ⭐ | Learning basics |
| **basic** | Functional | Top | ⭐⭐ | Daily use |
| **intermediate** | Integrated | Top | ⭐⭐⭐ | System integration |
| **maximal** | Complete | Custom | ⭐⭐⭐⭐⭐ | Reference/study |
| **catppuccin** | Colorful | Top | ⭐⭐ | Beautiful colors |
| **macos** | Clean | Top | ⭐⭐ | macOS aesthetic |
| **windows11** | Modern | Bottom | ⭐⭐ | Windows style |
| **gnome** | Minimal | Top | ⭐⭐ | GNOME feel |

---

## 🎨 What Each Config Looks Like

### minimal
```
┌─────────────────────────────────────────┐
│ WS: 1                              14:30 │
└─────────────────────────────────────────┘
```

### basic
```
┌─────────────────────────────────────────────────────────────┐
│ [WS: 1 2 3 4 5]  No active window    [🔔 Tray] [🔊 75%] [🔋 85%] [14:30] │
└─────────────────────────────────────────────────────────────┘
```

### catppuccin
```
┌──────────────────────────────────────────────────────────────────┐
│ [🥭] [I II III IV V]   [Ghostty]   [💻 23% 🧠 45%] [🔊 75%] [⚡ 85%] [14:30] │
└──────────────────────────────────────────────────────────────────┘
```

### macos
```
┌──────────────────────────────────────────────────────────┐
│ [① ② ③ ④]          Mon Jan 15  2:30 PM       📶 🔋 85% ⚙️ │
└──────────────────────────────────────────────────────────┘
```

### windows11 (bottom)
```
┌──────────────────────────────────────────────────────────┐
│                                                          │
│  (desktop content)                                       │
│                                                          │
├──────────────────────────────────────────────────────────┤
│ [1][2][3][4]  [⊞][🔍][📋] [📁][🌐][💬]     🔊📶🔋 2:30 PM 🔔│
└──────────────────────────────────────────────────────────┘
```

### gnome
```
┌──────────────────────────────────────────────────────────┐
│ Activities          Mon Jan 15  14:30      📶 🔊 ⚡ ▼    │
└──────────────────────────────────────────────────────────┘
```

---

## 🔧 Making Your First Modification

### Example: Change Clock Format in minimal

1. Open the file:
```bash
nvim ~/nixos-config/modules/home/quickshell-configs/minimal/shell.qml
```

2. Find this line:
```qml
clockText.text = Qt.formatTime(new Date(), "HH:mm")
```

3. Change it:
```qml
// 12-hour format with AM/PM
clockText.text = Qt.formatTime(new Date(), "h:mm AP")

// Or with seconds
clockText.text = Qt.formatTime(new Date(), "HH:mm:ss")

// Or include date
clockText.text = Qt.formatDateTime(new Date(), "HH:mm | MMM d")
```

4. Save and test:
```bash
quickshell -p ~/nixos-config/modules/home/quickshell-configs/minimal
```

---

## 💡 Quick Experiments

### Experiment 1: Change Colors
In any config, modify color values:
```qml
// Change from default to your preference
color: "#cdd6f4"  // Try "#ff0000" for red, "#00ff00" for green
```

### Experiment 2: Move Bar to Bottom
Change anchors:
```qml
anchors {
    bottom: true  // Instead of top: true
    left: true
    right: true
}
```

### Experiment 3: Add a Widget
Copy a Text element and modify it:
```qml
Text {
    text: "Hello!"
    color: "#cdd6f4"
    font.pixelSize: 13
}
```

---

## 📚 Next Steps After Testing

1. **Pick your favorite** themed config as inspiration
2. **Start with minimal** as your base
3. **Add features** one at a time from other configs
4. **Study maximal** when you want to understand advanced patterns
5. **Create your own** unique combination

---

## ❓ Troubleshooting

### Config doesn't load?
Check for syntax errors:
```bash
# Look for error messages in terminal
quickshell -p ~/nixos-config/modules/home/quickshell-configs/minimal
```

### Can't see the bar?
- Make sure PanelWindow anchors are set correctly
- Check that `implicitHeight` is set
- Verify screen detection works

### Colors look wrong?
- Ensure you're using valid hex color codes
- Check opacity values (0.0 to 1.0)
- Verify theme colors are defined

### Need help?
- Read the error message carefully
- Check `GALLERY-README.md` for documentation
- Compare with working configs
- Study ekremx25 reference implementation

---

## 🎯 Recommended Testing Order

1. ✅ **minimal** - Understand the basics (5 min)
2. ✅ **catppuccin** - See beautiful styling (5 min)
3. ✅ **macos** - Learn blur effects (5 min)
4. ✅ **basic** - See more widgets (5 min)
5. ✅ **windows11** - Different layout approach (5 min)
6. ✅ **gnome** - Minimalist design (5 min)
7. 📖 **intermediate** - Study integration patterns (15 min)
8. 📖 **maximal** - Browse full feature set (30 min)

Total time: ~1 hour to explore everything!

---

## 🚀 Ready to Build?

Once you've tested all configs:

1. Choose your favorite elements from each
2. Start with `minimal` as your foundation
3. Add features gradually
4. Create something uniquely yours!

Happy building! 🎨✨
