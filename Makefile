build:
	nix build .#nixosConfigurations.hostname.config.system.build.toplevel
build-vm:
	nix build .#nixosConfigurations.vm.config.system.build.vm
check:
	nix flake check

# --- Installation helpers ---------------------------------------------------
#
# The real-hardware disk layout is declared via disko (modules/disko.nix).
# No hardware-configuration.nix placeholder is needed, so the repo stays
# clean and the VM needs no git-tree tricks.
#
# From the NixOS minimal installer (where `make` is not available), run the
# raw nix command shown in README.md instead of `make install`.

# GTK display: opens a local window automatically.
# Press Ctrl+C in this terminal to stop the VM.
run:
	QEMU_KERNEL_PARAMS=console=ttyS0 ./result/bin/run-creation-station-vm

run-cli:
	QEMU_KERNEL_PARAMS=console=ttyS0 ./result/bin/run-creation-station-vm -nographic; reset
