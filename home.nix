# home.nix
#
# Home Manager entry point for user `sam`: identity, the shared package set,
# and misc program config. Desktop (mangowm) and VM concerns live under
# modules/home/ and are imported below.
{ pkgs, lib, ... }:

let
  # NOTE :: other aliases may be set by their respective modules; i.e. neovim.
  # Make sure to check modules/home if you are unsure if an alias exists.
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
    ./bitwig.nix
    ./modules/home/mango.nix
    ./modules/home/neovim.nix
    ./modules/home/noctalia.nix
    ./modules/home/vm-resize.nix
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
    cura-appimage
    dbeaver-bin
    docker-sbx
    firefox
    ghostty
    freecad
    gimp
    impala
    inkscape
    libation
    nixos-artwork.wallpapers.recursive
    nixos-artwork.wallpapers.gear
    nixos-artwork.wallpapers.waterfall
    nixos-artwork.wallpapers.nineish
    nixos-artwork.wallpapers.stripes
    nixos-artwork.wallpapers.dracula
    nixos-artwork.wallpapers.moonscape
    nixos-artwork.wallpapers.simple-red
    nixos-artwork.wallpapers.binary-red
    nixos-artwork.wallpapers.simple-blue
    nixos-artwork.wallpapers.binary-blue
    nixos-artwork.wallpapers.mosaic-blue
    nixos-artwork.wallpapers.watersplash
    nixos-artwork.wallpapers.stripes-logo
    nixos-artwork.wallpapers.binary-white
    nixos-artwork.wallpapers.binary-black
    nixos-artwork.wallpapers.nineish-solarized-dark
    nixos-artwork.wallpapers.nineish-solarized-light
    noto-fonts
    obsidian
    openscad
    orca-slicer
    proton-authenticator
    proton-pass
    proton-pass-cli
    proton-vpn
    proton-vpn-cli
    protonmail-desktop
    rclone
    simple-scan
    # steam
    thorium-reader
    wiremix
    yazi
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
      $DRY_RUN_CMD noctalia msg config-reload 2>/dev/null || true
    '';
  };

  targets.genericLinux.enable = true;
  targets.genericLinux.gpu.enable = true;

  xdg.configFile = {
    "yazi/yazi.toml".text = builtins.readFile ./modules/home/yazi.toml;
  };
}
