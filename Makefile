build:
	nix build .#nixosConfigurations.hostname.config.system.build.toplevel
build-vm:
	nix build .#nixosConfigurations.vm.config.system.build.vm
check:
	nix flake check

# --- Hardware config: placeholder <-> real transition ------------------------
#
# `hardware-configuration.nix` in git is a portable placeholder (tmpfs root)
# so the flake evaluates anywhere. On a real install it must be replaced with
# the machine-specific config from `nixos-generate-config`. These targets
# handle that swap and keep the placeholder pristine in HEAD:
#   - `ROOT` is where the target machine's disks are mounted (default /mnt).
#   - `generate-hardware` runs the generator against ROOT, drops the result
#     into ./hardware-configuration.nix, then `skip-worktree`-pins it so the
#     real file is never committed.
#   - `restore-placeholder` undoes that and restores the committed placeholder
#     (for a fresh clone / another machine / reinstall).
ROOT ?= /mnt

.PHONY: generate-hardware restore-placeholder

generate-hardware:
	# Requires the target machine's disks to be mounted at ROOT (default /mnt).
	# nixos-generate-config errors out itself if ROOT isn't a real root.
	nixos-generate-config --root $(ROOT)
	cp $(ROOT)/etc/nixos/hardware-configuration.nix ./hardware-configuration.nix
	git update-index --skip-worktree hardware-configuration.nix
	@echo "Real hardware config written to ./hardware-configuration.nix (kept out of git)."

restore-placeholder:
	git update-index --no-skip-worktree hardware-configuration.nix
	git checkout -- hardware-configuration.nix
	@echo "Restored committed placeholder hardware-configuration.nix."
# Display adapter for mangowm visibility in the VM is configured declaratively
# in modules/vm.nix (`virtualisation.qemu.options`: use the dedicated
# `virtio-vga-gl` device, NOT `virtio-gpu-pci,gl=on` which has no `gl` property
# on QEMU 11.1; `-vga none` drops the default bochs adapter). Don't add a
# second display device here - two outputs is what broke the earlier attempt.
# `make run` needs a FRESH `make build-vm` result so the QEMU binary includes
# virgl (an old `./result` will fail with "Property not found").
run:
	QEMU_KERNEL_PARAMS=console=ttyS0 ./result/bin/run-creation-station-vm
# NOTE: run-cli (-nographic) conflicts with the VM's `-display gtk,gl=on`
# above. For a serial-only log capture, temporarily drop those qemu.options
# (or set virtualisation.graphics = false) when rebuilding the VM.
run-cli:
	QEMU_KERNEL_PARAMS=console=ttyS0 ./result/bin/run-creation-station-vm -nographic; reset
