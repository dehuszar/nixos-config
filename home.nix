# home.nix
#
# Home Manager entry point for user `sam`: identity, the shared package set,
# and misc program config. Desktop (mangowm) and VM concerns live under
# modules/home/ and are imported below.
{ pkgs, ... }:

let
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

    # rss-social workflow
    rsss = "cd ~/Development/rss-social/";
    rsssnv = "cd ~/Development/rss-reader/ && nvim";

    # terraform workflow
    tfmt = "tf fmt -recursive";
    tfi = "terraform init";
    tfp = "terraform plan";
    tfa = "terraform apply";

    # vim workflow
    vim = "nvim";

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
    # 3D Slicers from nixpkgs 26.05
    blender
    cura-appimage
    dbeaver-bin
    docker-sbx
    firefox
    ghostty
    freecad
    gimp
    inkscape
    libation
    noto-fonts
    openscad
    orca-slicer
    proton-authenticator
    proton-pass
    proton-pass-cli
    proton-vpn
    proton-vpn-cli
    protonmail-desktop
    rclone
    # steam
    thorium-reader
    yazi
  ];

  fonts.fontconfig.enable = true;

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
    initExtra = builtins.readFile ./bashrc;
    shellAliases = shellAliases;
  };
  programs.pi-coding-agent.enable = true;

  targets.genericLinux.enable = true;
  targets.genericLinux.gpu.enable = true;
}
