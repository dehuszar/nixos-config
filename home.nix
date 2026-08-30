{
  config,
  pkgs,
  inputs,
  isVM ? false,
  ...
}:

{
  imports = [
    ./bitwig.nix
    inputs.mangowm.hmModules.mango
  ];

  # mangowm config. This Home Manager module is what writes
  # ~/.config/mango/config.conf (it only writes the file when the
  # config is non-empty). Nested attrs flatten to underscores, and
  # repeatable keys (like `bind`) are written as lists.
  wayland.windowManager.mango = {
    enable = true;
    settings = {
      # Renderer env. With the VM now exposing a real accelerated GPU via
      # virtio-gpu/virgl (see the VM-only qemu display module in flake.nix),
      # mangowm should use hardware GL just like on the real machine. The old
      # VM workaround (WLR_RENDERER_ALLOW_SOFTWARE / LIBGL_ALWAYS_SOFTWARE /
      # WLR_DRM_NO_ATOMIC) is no longer set because LIBGL_ALWAYS_SOFTWARE would
      # force llvmpipe even when virgl is available, turning the screen black
      # again. If virgl is ever unavailable, temporarily re-add those vars.
      env = [ ];

      # Window effects
      border_radius = 6;
      focused_opacity = 1.0;
      unfocused_opacity = 1.0;

      # fx post-processing (animations) is left off to keep the VM's
      # render/blit path simple (works under virgl and llvmpipe alike).
      animations = 0;

      # Repeatable key -> list of comma-separated bindings.
      # Action names mirror mango's bundled default config.
      bind = [
        "Super,r,reload_config"
        "Super,m,quit"
        "Alt,q,killclient,"
        "Alt,f,togglefullscreen,"
        "Alt,Left,focusdir,left"
        "Alt,Right,focusdir,right"
        "Alt,Up,focusdir,up"
        "Alt,Down,focusdir,down"
        # Launch a terminal (ghostty) — press Super+Return to test mango interactively.
        "Super,Return,spawn,ghostty"
        # Require the app installed; uncomment if you have them:
        # "Alt,space,spawn,rofi -show drun"
      ];
    };
    # Raw config lines appended verbatim (unsupported/advanced opts)
    extraConfig = "";
  };

  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "sam";
  home.homeDirectory = "/home/sam";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "26.11"; # Please read the comment before changing.

  # The home.packages option allows you to install Nix packages into your
  # environment.
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
    # steam
    thorium-reader
    yazi

    # # It is sometimes useful to fine-tune packages, for example, by applying
    # # overrides. You can do that directly here, just don't forget the
    # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
    # # fonts?
    # (pkgs.nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })

    # # You can also create simple shell scripts directly inside your
    # # configuration. For example, this adds a command 'my-hello' to your
    # # environment:
    # (pkgs.writeShellScriptBin "my-hello" ''
    #   echo "Hello, ${config.home.username}!"
    # '')
  ];

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
  };

  fonts.fontconfig.enable = true;

  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. These will be explicitly sourced when using a
  # shell provided by Home Manager. If you don't want to manage your shell
  # through Home Manager then you have to manually source 'hm-session-vars.sh'
  # located at either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/sam/etc/profile.d/hm-session-vars.sh
  #
  home.sessionVariables = {
    EDITOR = "nvim";
    SUDO_EDITOR = "nvim";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
  # pi-coding-agent appears to be on the unstable branch, not the current 26.05
  programs.pi-coding-agent.enable = true;

  targets.genericLinux.enable = true;
  targets.genericLinux.gpu.enable = true;
}
