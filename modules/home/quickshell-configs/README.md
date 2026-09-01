# Quickshell Configurations

This directory contains Quickshell configuration examples for learning and experimentation.

## Available Configs

### `default/` ⭐ Start Here
A minimal bar showing the current time. Perfect starting point for learning Quickshell.

**Features:**
- Multi-screen support
- Clean component structure
- Clock with formatted time
- Singleton pattern example

**Test it:**
```bash
quickshell -p ~/nixos-config/modules/home/quickshell-configs/default
```

---

### `026-transparency-blur/`
Demonstrates transparency and blur effects using Qt6's MultiEffect.

**Features:**
- Transparent panel background
- Gaussian blur effect
- Modern Qt6 approach (no Qt5 dependencies)

**Note:** This was updated to use `QtQuick.Effects.MultiEffect` instead of the deprecated `Qt5Compat.GraphicalEffects`.

---

## How to Switch Between Configs

Edit `../quickshell.nix` and change the `activeExample` variable:

```nix
activeExample = "default";  # or "transparency-blur"
```

Then rebuild your VM:
```bash
make vm-build
make vm-run
```

---

## Creating New Examples

1. Copy an existing config:
   ```bash
   cp -r default 001-my-new-example
   ```

2. Make your changes in the new directory

3. Add it to `../quickshell.nix`:
   ```nix
   configs = {
     default = ./quickshell-configs/default;
     transparency-blur = ./quickshell-configs/026-transparency-blur;
     my-new-example = ./quickshell-configs/001-my-new-example;  # Add this
   };
   ```

4. Switch to it by updating `activeExample`

5. Test:
   ```bash
   quickshell -p ~/nixos-config/modules/home/quickshell-configs/001-my-new-example
   ```

---

## Learning Resources

See `../../QUICKSHELL-LEARNING-PATH.md` for a guided learning path from minimal to full desktop.

---

## Structure

Each config directory should contain:
- `shell.qml` - Entry point
- `Bar.qml` or similar - Main panel component
- Additional `.qml` files for widgets/components
- Optional: `README.md` explaining the example

Keep each example focused on specific concepts to make learning easier!
