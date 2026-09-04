# modules/first-boot.nix
#
# One-shot systemd service that runs on first boot and sets up the
# nixos-config repo in ~sam/nixos-config.  The repo is cloned via HTTPS
# (public), and the SSH remote is pre-configured so pushes work as soon
# as the user adds their SSH key.
{ config, pkgs, lib, ... }:

{
  systemd.services.clone-nixos-config = {
    description = "Clone nixos-config repo on first boot";
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      User = "sam";
      RemainAfterExit = "no";
    };
    script = ''
      REPO_DIR="/home/sam/nixos-config"
      HTTPS_URL="https://github.com/dehuszar/nixos-config.git"
      SSH_URL="git@github.com:dehuszar/nixos-config.git"

      if [ -d "$REPO_DIR/.git" ]; then
        echo "nixos-config repo already exists at $REPO_DIR, skipping."
        exit 0
      fi

      echo "Cloning nixos-config repo..."
      git clone "$HTTPS_URL" "$REPO_DIR"

      # Switch the remote to SSH so pushes work once SSH keys are set up.
      cd "$REPO_DIR"
      git remote set-url origin "$SSH_URL"

      echo "Done.  Config repo is at $REPO_DIR (remote set to SSH)."
    '';
    # Remove this unit after it succeeds so it doesn't run again on
    # subsequent boots (and so a re-install of the same config won't
    # clobber a working checkout).
    unitConfig.ConditionPathExists = "!/home/sam/nixos-config/.git";
  };
}
