# Quickshell Configuration Gallery

This directory contains multiple Quickshell configurations organized by complexity and theme. Switch between them easily to learn, experiment, and find your perfect desktop setup.

---

## 🎯 How to Switch Configs

Edit `../quickshell.nix` and change the `activeExample` variable:

```nix
activeExample = "minimal";  # Change this to any config name below
```

Then rebuild your VM:
```bash
make vm-build
make vm-run
```

Or test directly in the VM:
```bash
quickshell -p ~/nixos-config/modules/home/quickshell-configs/[config-name]
```

---

## 📚 Progressive Learning Path

Start simple and add complexity as you learn. Each level builds on the previous one.

### 1. **minimal** ⭐ START HERE
**Complexity:** ⭐ Very Simple  
**Purpose:** Just the essentials - workspaces and clock  
**Best for:** Understanding basic structure

**Features:**
- Workspace indicator (static)
- Clock with time display
- Clean layout

**What you'll learn:**
- PanelWindow basics
- Simple layouts
- Timer-based updates

**Test it:**
```bash
quickshell -p ~/nixos-config/modules/home/quickshell-configs/minimal
```

---

### 2. **basic**
**Complexity:** ⭐⭐ Simple  
**Purpose:** Essential desktop functionality  
**Best for:** Daily use while learning

**Features:**
- Workspaces (styled)
- Active window title (placeholder)
- System tray placeholder
- Volume indicator
- Battery status
- Clock

**What you'll learn:**
- Multiple widgets
- Layout management
- Visual grouping

**Test it:**
```bash
quickshell -p ~/nixos-config/modules/home/quickshell-configs/basic
```

---

### 3. **intermediate**
**Complexity:** ⭐⭐⭐ Medium  
**Purpose:** Real system integration  
**Best for:** Understanding MangoWM integration

**Features:**
- Dynamic workspace indicators
- Active window tracking (TODO)
- Real battery monitoring (TODO)
- Real volume control (TODO)
- System information

**What you'll learn:**
- Process execution
- System service integration
- MangoWM IPC with `mmsg`
- State management

**Files to study:**
- Shell structure for MangoWM integration
- Service patterns (commented out for now)

**Test it:**
```bash
quickshell -p ~/nixos-config/modules/home/quickshell-configs/intermediate
```

---

### 4. **maximal**
**Complexity:** ⭐⭐⭐⭐⭐ Advanced  
**Purpose:** Full ekremx25 feature set  
**Best for:** Reference and inspiration

**Features:**
- Everything from ekremx25/quickshell
- 30+ modules
- Complete desktop shell

**What you'll learn:**
- Professional code structure
- Advanced QML patterns
- Complex state management
- Modular architecture

**Warning:** This is complex! Use as reference, not as your daily driver yet.

**Directory structure:**
```
maximal/
├── shell.qml           # Entry point with staged loading
├── Modules/            # All bar modules
├── Services/           # Backend services
├── Widgets/            # Reusable components
└── Components/         # UI components
```

**Browse it:**
```bash
ls modules/home/quickshell-configs/maximal/Modules/bar/
```

---

## 🎨 Themed Variations

Pre-styled configs inspired by popular desktop environments. Great for seeing different design approaches!

### **catppuccin** 🦋
**Style:** Catppuccin Mocha color palette  
**Inspired by:** Catppuccin theme project  
**Best for:** Beautiful, cohesive colors

**Features:**
- Complete Catppuccin Mocha palette
- Color-coded system info
- Roman numeral workspaces
- Rounded corners throughout
- Accent-colored clock

**Colors used:**
- Base: `#1e1e2e` (dark background)
- Blue: `#89b4fa` (accents)
- Green: `#a6e3a1` (battery)
- Peach: `#fab387` (CPU)
- And more...

**Test it:**
```bash
quickshell -p ~/nixos-config/modules/home/quickshell-configs/catppuccin
```

---

### **macos** 🍎
**Style:** macOS menu bar aesthetic  
**Inspired by:** macOS Big Sur/Monterey  
**Best for:** Clean, minimal design lovers

**Features:**
- Frosted glass blur effect
- Centered date and time
- Pill-shaped workspace indicators
- Subtle transparency
- Right-aligned system icons

**Design elements:**
- Blur via QtQuick.Effects.MultiEffect
- SF Pro-like typography
- Minimalist iconography
- Soft shadows

**Test it:**
```bash
quickshell -p ~/nixos-config/modules/home/quickshell-configs/macos
```

---

### **windows11** 🪟
**Style:** Windows 11 taskbar  
**Inspired by:** Windows 11 centered taskbar  
**Best for:** Familiar Windows workflow

**Features:**
- Bottom-positioned bar (like taskbar)
- Centered app icons
- Start button
- System tray on right
- Task View and Search buttons
- Active window indicators

**Design elements:**
- Acrylic background effect
- Centered layout
- Square icons with rounded corners
- Blue accent color (`#0078d4`)

**Test it:**
```bash
quickshell -p ~/nixos-config/modules/home/quickshell-configs/windows11
```

---

### **gnome** 🐧
**Style:** GNOME top bar  
**Inspired by:** GNOME Shell  
**Best for:** Linux purists

**Features:**
- Top-positioned bar
- "Activities" button (left)
- Centered date and time
- System menu (right)
- Dark theme
- Minimal spacing

**Design elements:**
- Dark background (`#1e1e1e`)
- White text
- Compact layout
- System menu dropdown style

**Test it:**
```bash
quickshell -p ~/nixos-config/modules/home/quickshell-configs/gnome
```

---

## 🔄 Original Configs

Your starting points and experiments.

### **default**
Your original minimal config with clock. The foundation everything else builds on.

### **transparency-blur**
Qt6-compatible transparency and blur effects example. Fixed from Qt5 dependencies.

---

## 📖 Learning Strategy

### Week 1: Understand the Basics
```bash
# Study minimal config
cat minimal/shell.qml

# Understand each line
# Question: What does PanelWindow do?
# Question: How does the Timer work?
```

### Week 2: Add One Feature
```bash
# Copy minimal to new dir
cp -r minimal my-experiment

# Add a battery indicator
nvim my-experiment/shell.qml

# Test it
quickshell -p ~/nixos-config/modules/home/quickshell-configs/my-experiment
```

### Week 3: Study Themes
```bash
# Compare catppuccin and macos
diff catppuccin/shell.qml macos/shell.qml

# Learn different styling approaches
# Borrow ideas you like
```

### Week 4: Explore Maximal
```bash
# Browse the full feature set
ls maximal/Modules/bar/

# Pick ONE module to understand
cat maximal/Modules/bar/ClockBlock/ClockBlock.qml

# Create simplified version
```

---

## 🎓 Key Concepts by Level

### Minimal Level
- ✅ PanelWindow
- ✅ Anchors
- ✅ Text widgets
- ✅ Timers
- ✅ Basic layouts

### Basic Level
- ✅ Rectangle styling
- ✅ Row/Column layouts
- ✅ Multiple sections
- ✅ Visual hierarchy
- ✅ Spacing and margins

### Intermediate Level
- ✅ Process execution
- ✅ System integration
- ✅ State management
- ✅ Dynamic content
- ✅ Error handling

### Maximal Level
- ✅ Staged loading
- ✅ Service architecture
- ✅ Component composition
- ✅ Configuration files
- ✅ Plugin systems

---

## 💡 Tips for Learning

1. **Start with minimal** - Don't skip ahead!
2. **Read every line** - Understand what each part does
3. **Make small changes** - Change colors, spacing, text
4. **Test immediately** - See results of each change
5. **Commit often** - Save working versions
6. **Compare configs** - See different approaches
7. **Ask questions** - When confused, investigate!

---

## 🔧 Customization Ideas

Want to make your own? Try these modifications:

### Easy Changes
- Change colors
- Adjust spacing
- Modify font sizes
- Add emojis
- Rearrange widgets

### Medium Changes
- Add new widgets
- Create custom shapes
- Implement hover effects
- Add animations
- Change bar position (top/bottom)

### Advanced Changes
- Integrate with MangoWM
- Add real system monitoring
- Create popup menus
- Implement drag-and-drop
- Build settings panel

---

## 📝 Notes Template

When studying a config, fill this out:

```markdown
# Config: [name]

## What I Like
- 
- 
- 

## What Confuses Me
- 
- 
- 

## Ideas to Steal
- 
- 
- 

## My Modifications
- 
- 
- 
```

---

## 🚀 Next Steps

1. **Today:** Test the `minimal` config
2. **This week:** Study `basic` and `catppuccin`
3. **Next week:** Try creating your own variation
4. **Month 1:** Understand `intermediate` patterns
5. **Month 2+:** Explore `maximal` for advanced features

Remember: The goal is understanding, not copying! Build your own unique desktop. 🎨
