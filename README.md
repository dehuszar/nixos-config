# nixos-config

NixOS + Home Manager + mangowm configuration for `creation-station`.

This repo exposes **two** NixOS configurations built from one set of shared
modules, selected by an `isVM` flag threaded through `flake.nix`'s
`specialArgs`:

| Configuration | `isVM` | Purpose |
|---|---|---|
| `nixosConfigurations.hostname` | `false` | The real hardware target. Uses the GPU, no VM workarounds. |
| `nixosConfigurations.vm` | `true` | A QEMU test VM. Injects software-rendering env so mangowm runs under QEMU's GPU-less display. |

The only config difference between the two is the mangowm `env` block in
`home.nix`:

```nix
env = if isVM then [
  "WLR_RENDERER_ALLOW_SOFTWARE,1"
  "LIBGL_ALWAYS_SOFTWARE,1"
  "WLR_DRM_NO_ATOMIC,1"
] else [];   # real hardware -> empty -> GPU rendering
```

---

## Prerequisites

- **Nix** with flakes enabled (`nix-command`, `flakes`). On NixOS these are
  already on by default in current releases.
- From this directory, i.e. `cd` into the repo.

---

## Workflow 1 — Test in the VM

The VM lets you verify mangowm boots and runs before touching real hardware.

### Build the VM

```bash
make build
# equivalent:
# nix build .#nixosConfigurations.vm.config.system.build.vm
```

The result is symlinked to `./result`.

### Run the VM

Graphical window (GPU-less / software rendering):

```bash
make run
```

Serial/CLI only (for capturing logs, no window):

```bash
make run-vm-cli
```

### In the VM

- greetd **auto-logs-in** to `sam` and launches mangowm automatically.
- **Launch ghostty** (your terminal):
  - in the QEMU window, click inside, then press `Super+Return`, **or**
  - if the host steals the key, enable QEMU input grab (`Ctrl+Alt+G`), then
    press `Super+Return`, **or**
  - via the QEMU monitor: press `Ctrl+Alt+2`, type `sendkey meta_l-ret`, Enter,
    then `Ctrl+Alt+1` to return to the display.

> **Note:** the VM has no GPU, so everything renders in software (llvmpipe).
> Mangowm starts and accepts clients, but **client window content will appear
> black** (the compositor cannot import dma-buf/GL textures under software
> rendering). This is a known VM limitation and does **not** reproduce on real
> hardware. Use the VM to prove the config *boots and runs*, not to view a
> desktop.

### Useful mangowm keys (from `home.nix`)

| Keys | Action |
|---|---|
| `Super+Return` | spawn `ghostty` |
| `Super+r` | reload mangowm config |
| `Super+m` | quit mangowm |
| `Alt+q` | close focused window |
| `Alt+f` | toggle fullscreen |
| `Alt+Left/Right/Up/Down` | move focus |

---

## Workflow 2 — Bootstrap the real installation

1. **Get the repo onto the target machine** (or generate the config on the
   target after a base install).

2. **Generate the real hardware config** on the target. From a live NixOS
   installer with your root mounted (e.g. at `/mnt`):

   ```bash
   nixos-generate-config --root /mnt
   ```

   This writes real `fileSystems` (device/UUID), swap, firmware, GPU, and
   network options.

3. **Replace the placeholder** in this repo with the generated one:

   ```bash
   cp /mnt/etc/nixos/hardware-configuration.nix ./hardware-configuration.nix
   ```

   > The placeholder in this repo is a tmpfs root created only so
   > `nix flake check` passes before real hardware exists. Do **not** install
   > with it. Always replace it with the generated file.

4. **Build the real machine**:

   ```bash
   nix build .#nixosConfigurations.hostname.config.system.build.toplevel
   ```

5. **Install** it (from the installer/live environment):

   ```bash
   sudo nixos-install --flake .#hostname
   ```

   (Once the generated `hardware-configuration.nix` is committed, repeat the
   same against your install media as needed.)

6. **Extras on the new install** (not yet in this repo — per-machine):
   - network interfaces / wifi, `networking.hostName`, firewall
   - boot device (the placeholder uses `systemd-boot` + EFI)
   - confirm `users.users.sam.initialPassword` is changed / a key added

---

## Validation commands

```bash
# whole flake evaluates cleanly (checks every configuration)
nix flake check

# VM build
make
# or
nix build .#nixosConfigurations.vm.config.system.build.vm

# real hardware build
nix build .#nixosConfigurations.hostname.config.system.build.toplevel

# confirm the VM/realtime env split behaves as intended:
nix eval .#nixosConfigurations.hostname.config.home-manager.users.sam.wayland.windowManager.mango.settings.env
# -> should be [ ]  (GPU)

nix eval .#nixosConfigurations.vm.config.home-manager.users.sam.wayland.windowManager.mango.settings.env
# -> should list the three WLR_/LIBGL_ software-rendering vars
```

---

## Layout

| File | Role |
|---|---|
| `flake.nix` | Flake: inputs, `mkNixos` builder, `hostname` + `vm` configs |
| `configuration.nix` | Shared NixOS config (boot, greetd+seatd, users, mango NixOS module) |
| `home.nix` | Shared home-manager config (packages, mangowm settings + bindings) |
| `hardware-configuration.nix` | **Placeholder** real-hardware FS — replace on install |
| `vm-root.nix` | Low-precedence tmpfs root so `vm` passes `nix flake check` |
| `bitwig.nix` | Imported home-manager module (packages) |
| `Makefile` | `build`, `run`, `run-vm-cli` targets |