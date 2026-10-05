This folder is for the placement of applications and plugins which do not easily conform to NixOS's concept of a read-only store.

For those programs, you can put the installer files in here, and then create a derivation which will install them as needed, ensuring their dependencies are available and not garbage collected.
