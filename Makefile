build:
	nix build .#nixosConfigurations.hostname.config.system.build.vm
	nix build-vm .#nixosConfigurations.vm.config.system.build.vm
# Use the NixOS VM's default single display adapter (bochs std VGA, which
# mangowm already detects as 1234:1111). Adding -device virtio-vga on top
# created a second output mangowm rendered to but the window didn't show.
run:
	QEMU_KERNEL_PARAMS=console=ttyS0 ./result/bin/run-creation-station-vm
run-cli:
	QEMU_KERNEL_PARAMS=console=ttyS0 ./result/bin/run-creation-station-vm -nographic; reset
