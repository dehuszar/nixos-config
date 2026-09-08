build:
	nix build --impure .#nixosConfigurations.hostname.config.system.build.toplevel
switch:
	sudo -E HOME=$(HOME) nixos-rebuild switch --impure --flake .#hostname
build-vm:
	nix build --impure .#nixosConfigurations.vm.config.system.build.vm
check:
	nix flake check --impure

# --- Proprietary sources ---------------------------------------------------
#
# Modartt uses expiring session-scoped download URLs, so the tarball must be
# downloaded manually.  Place it in sources/ then run make sources-prefetch.

sources/pianoteq_setup_v924.tar.xz:
	@echo "Download pianoteq_setup_v924.tar.xz from modartt.com"
	@echo "  → https://www.modartt.com/download?file=pianoteq_setup_v924.tar.xz"
	@echo "and place it in sources/"
	@exit 1

sources-prefetch: sources/pianoteq_setup_v924.tar.xz
	nix-prefetch-url file://$$(pwd)/$<

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
