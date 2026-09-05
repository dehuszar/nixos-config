# modules/home/mango.nix
#
# Home Manager side of mangowm: writes ~/.config/mango/config.conf from the
# structured `settings` below.
{ inputs, ... }:
{
  imports = [ inputs.mangowm.hmModules.mango ];

  wayland.windowManager.mango = {
    enable = true;
    # Raw config lines appended verbatim (unsupported/advanced opts)
    extraConfig = "";
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
      source = "~/.config/mango/noctalia.conf";

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
      animations = 1;

      # Repeatable key -> list of comma-separated bindings.
      # Action names mirror mango's bundled default config.
      bind = [
        # System
        "SUPER,comma,spawn,noctalia msg settings-toggle" # "Noctalia Settings"
        "SUPER,s,spawn,noctalia msg panel-toggle control-center"
        "SUPER,space,spawn,noctalia msg panel-toggle launcher"
        "Super+SHIFT,f,togglefullscreen,"
        "Super,g,toggleglobal"
        "SUPER,k,spawn,noctalia msg panel-toggle kenn/keybind-cheatsheet:cheatsheet"
        "Super,q,killclient,"
        "Super+SHIFT,r,reload_config"
        "Super,Return,spawn,ghostty" #"Terminal"
        "Super,b,spawn,firefox" #"Web browser"

        # Workspace / tag switching (Super+1 through Super+9)
        "Super,1,view,1"
        "Super,2,view,2"
        "Super,3,view,3"
        "Super,4,view,4"
        "Super,5,view,5"
        "Super,6,view,6"
        "Super,7,view,7"
        "Super,8,view,8"
        "Super,9,view,9"

        # Focus and Movement
        "Alt,Tab,focuslast"
        "Super,Down,focusdir,down"
        "Super,Left,focusdir,left"
        "Super,Right,focusdir,right"
        "Super,Up,focusdir,up"
        "Super+SHIFT,Down,focus_window_or_workspace,down"
        "Super+SHIFT,Left,focus_window_or_workspace,left"
        "Super+SHIFT,Right,focus_window_or_workspace,right"
        "Super+SHIFT,Up,focus_window_or_workspace,up"

        # Layouts
        "Super,F2,setlayout,scroller"
        "Super,F1,setlayout,tile"

        # Move focused window to tag (Super+Shift+1 through Super+Shift+9)
        "SUPER+SHIFT,1,tag,1"
        "SUPER+SHIFT,2,tag,2"
        "SUPER+SHIFT,3,tag,3"
        "SUPER+SHIFT,4,tag,4"
        "SUPER+SHIFT,5,tag,5"
        "SUPER+SHIFT,6,tag,6"
        "SUPER+SHIFT,7,tag,7"
        "SUPER+SHIFT,8,tag,8"
        "SUPER+SHIFT,9,tag,9"

        # Move focused window to tag, but preserve current workspace
        # (Super+Alt+1 through Super+Alt+9)
        "SUPER+ALT,1,tagsilent,1"
        "SUPER+ALT,2,tagsilent,2"
        "SUPER+ALT,3,tagsilent,3"
        "SUPER+ALT,4,tagsilent,4"
        "SUPER+ALT,5,tagsilent,5"
        "SUPER+ALT,6,tagsilent,6"
        "SUPER+ALT,7,tagsilent,7"
        "SUPER+ALT,8,tagsilent,8"
        "SUPER+ALT,9,tagsilent,9"

        # Media keys
        "NONE,XF86AudioRaiseVolume,spawn,noctalia msg volume-up"
        "NONE,XF86AudioLowerVolume,spawn,noctalia msg volume-down"
        "NONE,XF86AudioMute,spawn,noctalia msg volume-mute"
        "NONE,XF86MonBrightnessUp,spawn,noctalia msg brightness-up"
        "NONE,XF86MonBrightnessDown,spawn,noctalia msg brightness-down"


        # App launchers

        # TUI launchers
        "Super,n,spawn,ghostty -e nvim" # Nvim code editor (TUI)
        "Super,f,spawn,ghostty -e yazi" # File Browser (TUI)
      ];
    };
    systemd.enable = true;
    systemd.xdgAutostart = true;
  };
}
