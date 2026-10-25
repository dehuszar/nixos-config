# home.nix
#
# Home Manager entry point for user `sam`: identity, the shared package set,
# and misc program config. Desktop (mangowm) and VM concerns live under
# modules/home/ and are imported below.
{
  pkgs,
  lib,
  inputs,
  ...
}:

let
  # Wrapper that injects Proton secrets into the sbx sandbox before running pi.
  pi-sbx = pkgs.writeShellApplication {
    name = "pi-sbx.sh";
    runtimeInputs = [
      pkgs.proton-pass-cli
      pkgs.docker-sbx
      pkgs.jq
      pkgs.gnused
    ];
    text = ''
      # Usage: pi-sbx.sh SANDBOX_NAME [WORKDIR] [extra sbx args...]
      # (writeShellApplication already sets errexit/nounset/pipefail)

      if [ "$#" -lt 1 ]; then
        echo "usage: pi-sbx.sh SANDBOX_NAME [WORKDIR] [extra sbx args...]" >&2
        exit 1
      fi
      NAME="$1"
      shift

      WORKDIR="''${1:-.}"
      if [ "$#" -gt 0 ]; then shift; fi

      # Ensure we have an authenticated pass-cli session
      if ! pass-cli info >/dev/null 2>&1; then
        echo "No active pass-cli session. Logging in..."
        pass-cli login
      fi

      # Fetch secrets from pass-cli
      PASS_ITEM=$(pass-cli item view --vault-name Personal --item-title "Lemonade AI API Key" --output json)

      LEMONADE_API_KEY=$(echo "$PASS_ITEM" | jq -r '.item.content.content.Login.password')
      if [ -z "$LEMONADE_API_KEY" ] || [ "$LEMONADE_API_KEY" = "null" ]; then
        echo "error: could not read API key from pass item" >&2
        exit 1
      fi

      # Extract URLs — adjust selectors if your pass-cli output structure differs
      LEMONADE_API_DOMAIN_REMOTE=$(echo "$PASS_ITEM" \
        | jq -r '.item.content.content.Login.urls[] | select(contains("fort-towner"))' \
        | sed 's|/$||')/v1

      LEMONADE_API_DOMAIN_LOCAL=$(echo "$PASS_ITEM" \
        | jq -r '.item.content.content.Login.urls[] | select(contains("192.168"))' \
        | sed 's|/$||')/v1

      # docker-sbx v0.48.0 broke positional-arg volume mounting; workdir
      # is now derived from the cwd.
      cd "$WORKDIR"

      echo "Starting sandbox with lemonade AI providers..."
      echo "  Remote: $LEMONADE_API_DOMAIN_REMOTE"
      echo "  Local:  $LEMONADE_API_DOMAIN_LOCAL"

      # The kit extends the shell sandbox template, so pi is started by
      # handing -c pi to the in-sandbox shell after "--". The kit dir is
      # the first positional (sbx 0.48.0: --kit only accepts mixins).
      sbx run "$HOME/sbx-shell-pi" \
        --name "$NAME" \
        -e LEMONADE_API_KEY="$LEMONADE_API_KEY" \
        -e LEMONADE_API_DOMAIN_REMOTE="$LEMONADE_API_DOMAIN_REMOTE" \
        -e LEMONADE_API_DOMAIN_LOCAL="$LEMONADE_API_DOMAIN_LOCAL" \
        "$@" -- -c "pi"
    '';
  };

  # NOTE :: other aliases may be set by their respective modules.
  # Make sure to check modules/home or the nixos-devtools flake if you are
  # unsure if an alias exists.
  shellAliases = {
    # bitwig backup steps
    bkupBitwig = "AWS_PROFILE=wasabi rclone copy /home/sam/Bitwig\ Studio wasabi:sideffectstudios/Tracks/Bitwig\ Studio -vv --update";
    bkupBitwigMeta = "AWS_PROFILE=wasabi rclone copy /home/sam/.BitwigStudio wasabi:sideffectstudios/Tracks/.BitwigStudio -vv --update";

    # git workflow
    ga = "git add";
    gc = "git commit";
    gco = "git checkout";
    gcp = "git cherry-pick";
    gdiff = "git diff";
    gl = "git prettylog";
    gmff = "git merge --ff-only";
    gp = "git push";
    gpffo = "git pull --ff-only";
    gpfwl = "git push --force-with-lease";
    gs = "git status";
    gt = "git tag";

    # hashistack config workflow
    hscfg = "cd ~/Development/hashistack/hashistack-config/";
    hscfgnv = "cd ~/Development/hashistack/hashistack-config/ && nvim";

    # nomad job workflow
    njp = "nomad stop -purge $1";
    njpl = "nomad plan $1";
    njr = "nomad run $1";
    njs = "nomad stop $1";
    njst = "nomad status $1";

    # neovim workflow
    vim = "nvim";

    # rss-social workflow
    rsss = "cd ~/Development/rss-social/";
    rsssnv = "cd ~/Development/rss-reader/ && nvim";

    # terraform workflow
    tfmt = "tf fmt -recursive";
    tfi = "terraform init";
    tfp = "terraform plan";
    tfa = "terraform apply";

    # personal site workflow
    website = "cd ~/Development/samuel-allen.com/";
    websitenv = "cd ~/Development/samuel-allen.com/ && nvim";
    websitetmux = "cd ~/Development/samuel-allen.com/ && ./tmux-session.sh";
  };
in
{
  imports = [
    ./modules/home/mango.nix
    ./modules/home/mangobar.nix
    ./modules/home/wallust.nix
    ./modules/home/vm-resize.nix
    inputs.hashistack.homeManagerModules.controller
    inputs.nixos-devtools.homeManagerModules.dev
  ];

  home.username = "sam";
  home.homeDirectory = "/home/sam";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes. Do not change it; check the
  # release notes when updating.
  home.stateVersion = "26.11";

  home.packages = with pkgs; [
    blender
    bluetui
    btop
    chromium
    cura-appimage
    dbeaver-bin
    # freecad # temporarily disabled: ifcopenshell build broken in nixpkgs
    docker-sbx
    firefox
    ghostty
    gimp
    impala
    inkscape
    # ladybird
    libation
    mpv
    mpv-mpris
    obs-studio
    obs-studio-plugins.wlrobs
    obsidian
    openscad
    orca-slicer
    proton-authenticator
    proton-pass
    proton-pass-cli
    proton-vpn
    proton-vpn-cli
    protonmail-desktop
    libqalculate
    rclone
    signal-desktop
    simple-scan
    thorium-reader
    unzip
    wlogout
    awww
    waypaper
    yt-dlp
  ];

  fonts.fontconfig.enable = true;

  home.sessionPath = [
    "$HOME/.local/bin"
  ];

  home.sessionVariables = {
    EDITOR = "nvim";
    SUDO_EDITOR = "nvim";
  };

  programs.home-manager.enable = true;
  programs.bash = {
    enable = true;
    shellOptions = [ ];
    historyControl = [
      "ignoredups"
      "ignorespace"
    ];
    shellAliases = shellAliases;
  };
  programs.pi-coding-agent.enable = true;

  # Reload Mango config automatically after home-manager switch
  home.activation = {
    reloadMango = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      $DRY_RUN_CMD systemctl --user restart mangobar.service 2>/dev/null || true
    '';
  };

  targets.genericLinux.enable = true;
  targets.genericLinux.gpu.enable = true;

  services.hashistack.controller.enable = true;
  services.udiskie = {
    enable = true;
    settings = {
      # workaround for
      # https://github.com/nix-community/home-manager/issues/632
      program_options = {
        # replace with your favorite file manager
        file_manager = "${pkgs.yazi}/bin/yazi";
      };
    };
  };

  xdg.configFile = {
    "yazi/yazi.toml".text = builtins.readFile ./modules/home/yazi.toml;
  };

  # Symlink waypaper config directly from this repo (not the Nix store)
  # so that file changes are immediately available without rebuilding.
  home.activation.symlinkWaypaperConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    $DRY_RUN_CMD mkdir -p "$HOME/.config"
    $DRY_RUN_CMD ln -sfn /home/sam/nix/nixos-config/modules/home/waypaper "$HOME/.config/waypaper"
  '';

  # Install the pi-sbx wrapper script to ~/.local/bin.
  home.file.".local/bin/pi-sbx.sh".source = "${pi-sbx}/bin/pi-sbx.sh";
}
