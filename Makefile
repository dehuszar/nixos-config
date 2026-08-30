build:
	nix build .#nixosConfigurations.hostname.config.system.build.toplevel
build-vm:
	nix build .#nixosConfigurations.vm.config.system.build.vm
check:
	nix flake check
# Display adapter for mangowm visibility in the VM is configured declaratively
# in flake.nix's VM-only module (`virtualisation.qemu.options`: use the dedicated
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
