# modules/home/mango.nix
#
# Home Manager side of mangowm: writes ~/.config/mango/config.conf from the
# structured `settings` below.
{ inputs, ... }:
{
  imports = [ inputs.mangowm.hmModules.mango ];

  wayland.windowManager.mango = {
    enable = true;
    settings = {
      # Renderer env. With the VM now exposing a real accelerated GPU via
      # virtio-gpu/virgl (see modules/vm.nix), mangowm should use hardware GL
      # just like on the real machine. The old VM workaround
      # (WLR_RENDERER_ALLOW_SOFTWARE / LIBGL_ALWAYS_SOFTWARE /
      # WLR_DRM_NO_ATOMIC) is no longer set because LIBGL_ALWAYS_SOFTWARE would
      # force llvmpipe even when virgl is available, turning the screen black.
      # If virgl is ever unavailable, temporarily re-add those vars.
      env = [ ];
      exec-once = "quickshell";

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

        # App launchers
        "Super,Return,spawn,ghostty" # Terminal
        "Super,b,spawn,firefox" # Web browser

        # TUI launchers
        "Super,n,spawn,ghostty -e nvim" # Nvim code editor (TUI)
        "Super,w,spawn,ghostty -e wiremix" # Audio control (TUI)
      ];
    };
    # Raw config lines appended verbatim (unsupported/advanced opts)
    extraConfig = "";
  };
}
