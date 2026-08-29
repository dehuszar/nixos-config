build:
	nix build .#nixosConfigurations.hostname.config.system.build.vm
run:
	QEMU_KERNEL_PARAMS=console=ttyS0 ./result/bin/run-creation-station-vm -nographic; reset
