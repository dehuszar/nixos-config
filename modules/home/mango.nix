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
      exec-once = "noctalia";

      # Blur and shadows
      blur=1;
      blur_layer=0;
      blur_optimized=1;
      blur_params_num_passes=2;
      blur_params_radius=5;
      blur_params_noise=0.02;
      blur_params_brightness=0.9;
      blur_params_contrast=0.9;
      blur_params_saturation=1.0;
      layer_animations=0;
      
      shadows=1;
      layer_shadows=0;
      shadow_only_floating=0;
      shadows_size=4;
      shadows_blur=12;
      shadows_position_x=2;
      shadows_position_y=2;
      shadowscolor="0x000000ff";

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
        # Core binds
        "SUPER,space,spawn,noctalia msg panel-toggle launcher"
        "SUPER,s,spawn,noctalia msg panel-toggle control-center"
        "SUPER,comma,spawn,noctalia msg settings-toggle"

        # Media keys
        "NONE,XF86AudioRaiseVolume,spawn,noctalia msg volume-up"
        "NONE,XF86AudioLowerVolume,spawn,noctalia msg volume-down"
        "NONE,XF86AudioMute,spawn,noctalia msg volume-mute"
        "NONE,XF86MonBrightnessUp,spawn,noctalia msg brightness-up"
        "NONE,XF86MonBrightnessDown,spawn,noctalia msg brightness-down"

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
        "Super,x,spawn,firefox" # Web browser

        # TUI launchers
        "Super,n,spawn,ghostty -e nvim" # Nvim code editor (TUI)
        "Super,w,spawn,ghostty -e wiremix" # Audio control (TUI)
      ];
    };
    # Raw config lines appended verbatim (unsupported/advanced opts)
    extraConfig = "";
  };
}
