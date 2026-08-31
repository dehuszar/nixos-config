# modules/home/vm-resize.nix
#
# VM-only auto-resize watcher.
#
# QEMU's virtio-gpu signals a window resize by regenerating its EDID and
# firing a kernel hotplug event. The kernel re-probes the connector so
# /sys/class/drm/card0-Virtual-1/modes is always current (first line = the
# preferred mode). But wlroots' DRM backend only reacts to connect/
# disconnect transitions - virtio-gpu's connector stays "connected" and just
# swaps its mode list in place - so mango is never told and its cached mode
# list goes stale. This watcher subscribes to the kernel's hotplug uevent
# and, on each resize, has mango commit a custom mode at the new size via
# its output-management interface.
{ pkgs, lib, isVM ? false, ... }:
let
  vm-resize = pkgs.writeShellApplication {
    name = "mango-vm-resize";
    runtimeInputs = [
      pkgs.wlr-randr
      pkgs.systemd # for udevadm
      pkgs.coreutils # head, sleep
    ];
    text = ''
      conn="/sys/class/drm/card0-Virtual-1/modes"
      # Align to whatever mango picked at startup so we only act on changes
      # (avoids an unnecessary re-modeset at boot).
      applied="$(head -n1 "$conn" 2>/dev/null || true)"

      apply() {
        local cur i

        # The HOTPLUG uevent is emitted *before* the kernel re-probes the
        # connector, so /sys can still show the previous size for a few
        # instants. Poll until the preferred mode moves off the size we last
        # applied, then adopt it. (50ms * 20 = up to ~1s of settling time.)
        for ((i = 0; i < 20; i++)); do
          cur="$(head -n1 "$conn" 2>/dev/null || true)"
          if [[ "$cur" =~ ^[0-9]+x[0-9]+$ ]] && [ "$cur" != "$applied" ]; then
            if wlr-randr --output Virtual-1 --custom-mode "$cur"; then
              applied="$cur"
            fi
            return 0
          fi
          sleep 0.05
        done
      }

      # React to the kernel's DRM hotplug uevent (KOBJ_CHANGE + HOTPLUG=1 on
      # card0), raised every time QEMU's virtio-gpu is resized. udevadm
      # line-buffers and flushes after each event, so this pipe is a fully
      # event-driven replacement for the earlier `sleep 1` poll loop.
      udevadm monitor --kernel --subsystem-match=drm --property |
        while IFS= read -r line; do
          if [ "$line" = "HOTPLUG=1" ]; then
            apply
          fi
        done
    '';
  };
in
{
  # VM-only: launch the resize watcher when mango starts. It inherits mango's
  # WAYLAND_DISPLAY so wlr-randr can talk to the compositor. (`lib.optionalString`
  # keeps this empty - and the script unbuilt - on real hardware.)
  wayland.windowManager.mango.autostart_sh = lib.optionalString isVM ''
    ${vm-resize}/bin/mango-vm-resize &
  '';
}
