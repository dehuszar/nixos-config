# Bitwig Studio 6.1.1 Upgrade Instructions

## What's been done:

1. **Updated `modules/home/recording.nix`**: 
   - Added `bitwig-studio6-overridden` that overrides the nixpkgs version to 6.1.1
   - Updated `bitwig-studio-wrapped` to use the overridden version instead of `pkgs.bitwig-studio6`

## What you need to do:

### Step 1: Download Bitwig Studio 6.1.1
- Visit https://www.bitwig.com/ and download the Linux installer for version 6.1.1
- Or use your existing Bitwig account to access the download

### Step 2: Get the hash for the downloaded file
```bash
# After downloading the .deb file (it's actually a .deb inside the installer_linux file)
nix hash file /path/to/downloaded/installer_linux
```

The downloaded file will be named something like `installer_linux` but it's actually a Debian package.

### Step 3: Update the hash in recording.nix
Open `/home/sam/nixos-config/modules/home/recording.nix` and replace the placeholder hash:
```nix
hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
```
with the actual hash from Step 2.

### Step 4: Test the configuration
```bash
cd ~/nixos-config
nix flake lock --update-input nixpkgs
nix build .#nixosConfigurations.hostname.config.home-manager.users.sam.home.packages
```

### Step 5: Apply the changes
```bash
make switch
# or
sudo nixos-rebuild switch --flake .#hostname
```

## Notes:

- The overlay uses `overrideAttrs` which properly propagates the version change through the `finalAttrs` pattern used by the bitwig-studio6 package
- The URL pattern follows Bitwig's download structure: `https://www.bitwig.com/dl/Bitwig%20Studio/{version}/installer_linux`
- If the hash doesn't match, Nix will give you the expected hash in the error message - you can copy that directly
