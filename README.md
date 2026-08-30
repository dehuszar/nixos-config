# nixos-config

NixOS + Home Manager + mangowm configuration for `creation-station`.

This repo exposes **two** NixOS configurations built from one set of shared
modules, selected by an `isVM` flag threaded through `flake.nix`'s
`specialArgs`:

| Configuration | `isVM` | Purpose |
|---|---|---|
| `nixosConfigurations.hostname` | `false` | The real hardware target. Uses the GPU, no VM workarounds. |
| `nixosConfigurations.vm` | `true` | A QEMU test VM. Renders through virgl (host-side accelerated GL) via the VM-only qemu module. |

The only config difference between the two is the mangowm `env` block in
`home.nix` and, for the VM, the QEMU display adapter set in a **VM-only module**
in `flake.nix` (it deliberately lives there, not in shared `configuration.nix`,
so it can't break the real-hardware build):

```nix
# flake.nix -> nixosConfigurations.vm extraModules (VM-only):
# single virtio-gpu with virgl (host 3D) accel. `-vga none` drops the default
# bochs std VGA so there's exactly one output.
{
  virtualisation.graphics = true;
  virtualisation.qemu.options = [
    "-vga" "none"
    "-display" "gtk,gl=on"
    "-device" "virtio-vga-gl"
  ];
}
```

> Use the dedicated GL device `virtio-vga-gl` (NOT `virtio-gpu-pci,gl=on`,
> which has no `gl` property on QEMU 11.1 and fails with `Property
> 'virtio-gpu-pci.gl' not found`).

Both configs now render mangowm with real accelerated GL (virgl in the VM,
GPU on real hardware), so `env` is `[]` in both.

> **Display-accel note:** the VM's default adapter is bochs std VGA
> (unaccelerated), which left wlroots on llvmpipe where dma-buf/GL texture
> import fails and the desktop stays black. Replacing it with virtio-gpu+virgl
> gives the guest a real GL context so the full desktop (bar + windows + client
> content) draws in the QEMU window. Do **not** layer a second display device on
> top of bochs — two outputs renders to the one the window isn't showing. The
> VM also imports `qemu-vm.nix` explicitly (it's no longer in the default
> module list on 26.11). `make run` requires a freshly built `make build-vm`
> result — an old `./result` uses a QEMU without virgl and fails with
> `Property 'virtio-gpu-pci.gl' not found`.

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
make build-vm
# equivalent:
# nix build .#nixosConfigurations.vm.config.system.build.vm
#
# and the source config (real hardware) with:
# make build
# nix build .#nixosConfigurations.hostname.config.system.build.toplevel
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
- Launch ghostty (your terminal):
  - in the QEMU window, click inside, then press `Super+Return`, **or**
  - if the host steals the key, enable QEMU input grab (`Ctrl+Alt+G`), then
    press `Super+Return`, **or**
  - via the QEMU monitor: press `Ctrl+Alt+2`, type `sendkey meta_l-ret`, Enter,
    then `Ctrl+Alt+1` to return to the display.

> The VM renders the desktop through virtio-gpu/virgl (host-side 3D), so it
> should look like a real desktop. If you ever see the old black screen with
> only faint bars, the guest has fallen back to llvmpipe — re-check the QEMU
> `gl=on` flags and that the host QEMU window has a GL context.

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
make build-vm
# or
nix build .#nixosConfigurations.vm.config.system.build.vm

# real hardware build
make build

# confirm the VM uses accelerated GL (no llvmpipe env forcing) and a single
# virtio display:
nix eval .#nixosConfigurations.vm.config.home-manager.users.sam.wayland.windowManager.mango.settings.env
# -> should be [ ]

nix eval .#nixosConfigurations.vm.config.virtualisation.qemu.options
# -> [ "-vga" "none" "-device" "virtio-gpu-pci,gl=on" "-display" "gtk,gl=on" ]
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