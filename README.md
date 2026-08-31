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
`modules/home/mango.nix` and, for the VM, the QEMU display adapter set in the
**VM-only module** `modules/vm.nix` (it deliberately is not in shared
`configuration.nix`, so it can't break the real-hardware build):

```nix
# modules/vm.nix (imported only by nixosConfigurations.vm):
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
> VM also imports `qemu-vm.nix` explicitly in `modules/vm.nix` (it's no longer
> in the default module list on 26.11). `make run` requires a freshly built `make build-vm`
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
make run-cli
```

### In the VM

> **VM login password:** the VM gives `sam` the password `test` (`hashedPassword`,
> set in the VM-only `modules/vm.nix`). The graphical
> desktop auto-logs in via greetd (no password), but the **serial/CLI login
> (`make run-cli`) and any SSH into the VM need it**. The real-hardware config
> ships no password — set yours with `passwd` after install.

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

### Useful mangowm keys (from `modules/home/mango.nix`)

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

This repo stays portable: the committed `hardware-configuration.nix` is a
**placeholder** (tmpfs root, only so the flake evaluates anywhere), and the
real per-machine config is generated on the target and kept **out of git**, so
no disk layouts / UUIDs are published.

> **Where you run these steps:** everything in Workflow 2 runs from the
> **live/minimal installer** — the text-based NixOS ISO's shell — *not* from
> an already-installed system. Don't install a stock NixOS first and then
> bootstrap from it; this flow writes the final system directly via
> `nixos-install`. Once it finishes you `reboot` into the installed OS and
> follow the "Post-install & pre-bootstrap checklist" on that running system.

1. **Get the repo onto the target** (boot the NixOS installer/live medium;
   git, Nix + flakes are available there):

   ```bash
   git clone <repo-url>
   cd nixos-config
   ```

2. **Partition, format, and mount the target disks** so `/mnt` is the mounted
   root. BOTH `make generate-hardware` and `nixos-install` run against `/mnt`,
   so it must already point at your real disks. EFI example (adapt devices!):

   ```bash
   lsblk                        # find your disk, e.g. /dev/nvme0n1
   # create two partitions: 1) EFI system partition (512M, type ef00)
   #                        2) Linux root (rest, type 8304 / ext4)
   sudo mkfs.fat -F 32 -n ESP /dev/nvme0n1p1
   sudo mkfs.ext4 -L nixos /dev/nvme0n1p2

   sudo mount /dev/nvme0n1p2 /mnt
   sudo mkdir -p /mnt/boot
   sudo mount /dev/nvme0n1p1 /mnt/boot
   ```

3. **Generate the real hardware config — REQUIRED before installing**:

   ```bash
   make generate-hardware            # ROOT=/mnt (default)
   ```

   This runs `nixos-generate-config --root /mnt`, writes the result to
   `./hardware-configuration.nix`, and pins it with `git update-index
   --skip-worktree` so your disk layout is never committed to this public repo.
   To reset the placeholder (another machine / reinstall):

   ```bash
   make restore-placeholder
   ```

   > **Order matters!** The placeholder root is tmpfs *only so the flake
   > evaluates*. If you install without running `generate-hardware` first, the
   > system boots to a non-persistent, in-memory root. Run it before
   > `nixos-install`. Also confirm `/mnt` really holds your disks: the generated
   > `hardware-configuration.nix` should list real root/swap, not `tmpfs`.

4. **Confirm the target is EFI** — `configuration.nix` sets `systemd-boot` +
   `canTouchEfiVariables`. Adjust `boot.loader.*` for BIOS/MBR. Review the
   generated `hardware-configuration.nix` (root/swap) as needed.

5. **Install**:

   ```bash
   sudo nixos-install --flake .#hostname
   ```

   (Builds the full closure and activates into `/mnt`; needs network, can take
   a while.)

6. **Set your real password** (not stored in this public repo):

   ```bash
   passwd          # first log in as `sam`, then set a real password
   ```

7. **Networking is handled globally** via `networking.networkmanager.enable =
   true` (works on any machine, wired or wireless — see "Networking & wifi"
   below).

## Post-install & pre-bootstrap checklist

Run these once, right after the fresh install boots (auto-login lands you on
the mangowm desktop, with ghostty via `Super+Return`), before using the repo
as your working config:

1. **Set your user password** (not committed to this public repo; required before
   `sudo`). `sam` auto-logs into the desktop but is created with no password:

   ```bash
   passwd
   ```

2. **Connect to wifi** — NetworkManager is already enabled globally:

   ```bash
   nmcli device wifi list
   nmcli device wifi connect "SSID" password "pw"   # use `sudo nmcli` if polkit denies
   nmcli -t connection show --active      # confirm connected
   ```
   (GUI management lives in "Networking & wifi" below.)

3. **Set up a GitHub SSH key** so you can push changes back to the repo:
   ```bash
   ssh-keygen -t ed25519 -C "you@example.com"   # accept default ~/.ssh/id_ed25519
   cat ~/.ssh/id_ed25519.pub                     # copy the output
   ```
   Add the public key: GitHub → **Settings → SSH and GPG keys → New SSH key**.
   Test authentication:
   ```bash
   ssh -T git@github.com
   # -> Hi <you>! You've successfully authenticated, but GitHub does not
   #    provide shell access.
   ```

4. **Point the remote at your SSH URL** so future `git pull`/`push` use the
   key instead of HTTPS prompts:
   ```bash
   git remote set-url origin git@github.com:<you>/nixos-config.git
   git remote -v                                 # confirm
   ```

5. You're now ready to edit config and apply changes:
   ```bash
   git pull       # if you cloned earlier
   ...edit...
   git add -A && git commit -m "..." && git push
   sudo nixos-rebuild switch --flake .#hostname
   ```

## Networking & wifi

`networking.networkmanager.enable = true` is set globally in `configuration.nix`,
so NetworkManager drives both wired and wireless on any machine. No per-machine
networking is committed (keeps the repo public-portable).

From a bare mangowm desktop, open ghostty with `Super+Return` and use `nmcli`:

```bash
nmcli device status                                  # devices & state
nmcli device wifi list                               # scan
nmcli device wifi connect "SSID" password "pw"       # connect (profile is saved)
```

To manage saved connections graphically, add `networkmanagerapplet` to
`home.packages` and run `nm-connection-editor`. (A tray applet such as
`nm-applet` needs a system tray; mangowm's bar may not provide one, so CLI /
`nm-connection-editor` are the reliable routes on this desktop.)

## Fallback / recovery (when mangowm hangs or exits)

greetd runs mangowm on VT 1. Recovery paths:

- **Compositor exits/crashes** → greetd falls back to its `default_session` =
  `tuigreet` (a TUI greeter); pick mangowm again from there.
- **Compositor freezes** (no fall-through) → switch to a text console with
  **Ctrl+Alt+F2** … F6 (NixOS runs `agetty` logins on VTs 2–6 by default):

  ```bash
  journalctl -b -u greetd --no-pager | tail -50
  sudo systemctl restart greetd
  ```

- Mangowm keys: `Super+m` quits to the greeter; `Super+r` reloads the config.

Optional: a passwordless recovery console on a dedicated VT (auto-login):

```nix
# configuration.nix (NixOS)
systemd.services."getty@tty3" = {
  serviceConfig = {
    ExecStart = [
      ""   # clear the upstream ExecStart
      "${pkgs.util-linux}/sbin/agetty --autologin sam --noclear tty3 linux"
    ];
  };
};
```

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
# -> [ "-vga" "none" "-display" "gtk,gl=on" "-device" "virtio-vga-gl" ]
```

---

## Layout

| File | Role |
|---|---|
| `flake.nix` | Flake: inputs, `mkNixos` builder, `hostname` + `vm` configs |
| `configuration.nix` | Shared NixOS core (boot, hardware, locale, networking, users) |
| `home.nix` | Home Manager entry point (identity, shared packages, programs) |
| `modules/desktop.nix` | Desktop stack: mangowm (NixOS side), seatd, greetd |
| `modules/vm.nix` | VM-only: qemu-vm import, virtio-gpu display, tmpfs root, VM password |
| `modules/home/mango.nix` | Home Manager mangowm config (settings + bindings) |
| `modules/home/vm-resize.nix` | VM-only auto-resize watcher (event-driven) |
| `hardware-configuration.nix` | **Placeholder** real-hardware FS — replace on install |
| `bitwig.nix` | Imported home-manager module (packages) |
| `Makefile` | `build`, `build-vm`, `check`, `run`, `run-cli`, `generate-hardware`, `restore-placeholder` |