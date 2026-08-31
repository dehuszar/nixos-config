{
  config,
  pkgs,
  lib,
  inputs,
  isVM ? false,
  ...
}:

let
  # VM-only auto-resize watcher.
  #
  # QEMU's virtio-gpu signals a window resize by regenerating its EDID and
  # firing a kernel hotplug event. The kernel re-probes the connector so
  # /sys/class/drm/card0-Virtual-1/modes is always current (first line = the
  # preferred mode). But wlroots' DRM backend only reacts to connect/
  # disconnect transitions - virtio-gpu's connector stays "connected" and just
  # swaps its mode list in place - so mango is never told and its cached mode
  # list goes stale. This watcher subscribes to the kernel's hotplug uevent
  # and, on each resize, has mango commit a custom mode at the new size via
  # its output-management interface.
  vm-resize = pkgs.writeShellApplication {
    name = "mango-vm-resize";
    runtimeInputs = [
      pkgs.wlr-randr
      pkgs.systemd # for udevadm
      pkgs.coreutils # head, sleep
    ];
    text = ''
      conn="/sys/class/drm/card0-Virtual-1/modes"
      # Align to whatever mango picked at startup so we only act on changes
      # (avoids an unnecessary re-modeset at boot).
      applied="$(head -n1 "$conn" 2>/dev/null || true)"

      apply() {
        local cur i

        # The HOTPLUG uevent is emitted *before* the kernel re-probes the
        # connector, so /sys can still show the previous size for a few
        # instants. Poll until the preferred mode moves off the size we last
        # applied, then adopt it. (50ms * 20 = up to ~1s of settling time.)
        for ((i = 0; i < 20; i++)); do
          cur="$(head -n1 "$conn" 2>/dev/null || true)"
          if [[ "$cur" =~ ^[0-9]+x[0-9]+$ ]] && [ "$cur" != "$applied" ]; then
            if wlr-randr --output Virtual-1 --custom-mode "$cur"; then
              applied="$cur"
            fi
            return 0
          fi
          sleep 0.05
        done
      }

      # React to the kernel's DRM hotplug uevent (KOBJ_CHANGE + HOTPLUG=1 on
      # card0), raised every time QEMU's virtio-gpu is resized. udevadm prints
      # each event's properties and flushes after each one, so this pipe is a
      # fully event-driven replacement for the previous `sleep 1` poll loop.
      udevadm monitor --kernel --subsystem-match=drm --property |
        while IFS= read -r line; do
          if [ "$line" = "HOTPLUG=1" ]; then
            apply
          fi
        done
    '';
  };
in

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

    # VM-only: launch the resize watcher when mango starts. It inherits
    # mango's WAYLAND_DISPLAY so wlr-randr can talk to the compositor.
    autostart_sh = lib.optionalString isVM ''
      ${vm-resize}/bin/mango-vm-resize &
    '';
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
