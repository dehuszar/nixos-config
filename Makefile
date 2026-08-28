build:
	nix-build '<nixpkgs/nixos>' -A vm -I nixpkgs=channel:nixos-26.05 -I nixos-config=./configuration.nix
run:
	QEMU_KERNEL_PARAMS=console=ttyS0 ./result/bin/run-nixos-vm -nographic; reset
