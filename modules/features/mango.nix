{ inputs, ... }: {
  flake = {
    nixosModules.mango = { lib, ... }: {
      imports = [
        inputs.mango.nixosModules.mango
      ];

      options.hardware.gpu.nvidia = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable NVIDIA GPU support and NVIDIA-specific optimizations";
      };

      options.hardware.gpu.nvidiaOutput = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "Name of the output connected to the NVIDIA GPU (enables VRR there)";
      };

      config = {
        programs.mango.enable = true;

        services.displayManager.defaultSession = "mango";
      };
    };

    homeManagerModules.mango =
      {
        lib,
        systemTheme,
        mangoNvidia,
        mangoNvidiaOutput,
        ...
      }:
      let
        themes = import ../../themes-data.nix;
        colors = themes.${systemTheme}.colors;
        hex = color: "0x" + (lib.removePrefix "#" color) + "ff";
      in
      {
        imports = [
          inputs.mango.hmModules.mango
        ];

        wayland.windowManager.mango = {
          enable = true;

          systemd.variables = [
            "MANGO_INSTANCE_SIGNATURE"
          ];

          autostart_sh = ''
            wallpaper-init
            mako &
            clipman init -t mako &
            clipman listen &
            my-waybar &
          '';

          settings = {
            # Theming
            rootcolor = hex colors.bg;
            bordercolor = hex colors.border;
            focuscolor = hex colors.border-active;
            urgentcolor = hex colors.error;
            borderpx = 2;
            gappih = 2;
            gappiv = 2;
            gappoh = 2;
            gappov = 2;
            border_radius = 6;

            # Effects (blur behind transparent windows: alacritty + fuzzel)
            blur = 1;
            blur_layer = 1;
            blur_optimized = 1;
            blur_params = {
              radius = 5;
              num_passes = 1;
              noise = 0.02;
              brightness = 0.9;
              contrast = 0.9;
              saturation = 1.2;
            };

            # Animations (3x slower)
            animation_duration_move = 450;
            animation_duration_open = 450;
            animation_duration_tag = 300;
            animation_duration_close = 300;
            animation_duration_focus = 0;

            # Scroller layout on all tags (closest to niri's scrollable model)
            tag_num = 9;
            scroller_structs = 20;
            scroller_default_proportion = 0.5;
            scroller_focus_center = 0;
            scroller_prefer_center = 0;
            scroller_prefer_overspread = 1;
            scroller_proportion_preset = "0.5,0.8,1.0";
            edge_scroller_pointer_focus = 1;
            circle_layout = "scroller,fair";

            tagrule = [
              "id:*,layout_name:scroller"
            ];

            windowrule = [
              "isfloating:1,appid:float"
            ];

            layerrule = [
              "noanim:1,noblur:1,layer_name:selection"
              "noblur:1,layer_name:wlogout"
            ];

            # Input
            xkb_rules_layout = "us";
            sloppyfocus = 1;
            disable_while_typing = 1;
            tap_to_click = 1;

            # VRR on the NVIDIA output
            monitorrule = lib.optionals (mangoNvidia && mangoNvidiaOutput != null) [
              "name:^${mangoNvidiaOutput}$,vrr:1"
            ];

            # tag direction 
            tag_animation_direction = 0;

            bind = [
              # Launch
              "SUPER,Return,spawn,alacritty"
              "SUPER,D,spawn,fuzzel"
              "SUPER,V,spawn_shell,clipman pick -t fuzzel"
              "SUPER,Tab,spawn,librewolf"
              "SUPER,E,spawn,nautilus"

              # Wallpaper / overview
              "SUPER,n,spawn,wallpaper-next"
              "SUPER,o,toggleoverview"

              # Tags (workspaces)
              "SUPER,i,viewtoleft"
              "SUPER,u,viewtoright"
              "SUPER,1,view,1"
              "SUPER,2,view,2"
              "SUPER,3,view,3"
              "SUPER,4,view,4"
              "SUPER,5,view,5"
              "SUPER,6,view,6"
              "SUPER,7,view,7"
              "SUPER,8,view,8"
              "SUPER,9,view,9"
              "SUPER+SHIFT,1,tag,1"
              "SUPER+SHIFT,2,tag,2"
              "SUPER+SHIFT,3,tag,3"
              "SUPER+SHIFT,4,tag,4"
              "SUPER+SHIFT,5,tag,5"
              "SUPER+SHIFT,6,tag,6"
              "SUPER+SHIFT,7,tag,7"
              "SUPER+SHIFT,8,tag,8"
              "SUPER+SHIFT,9,tag,9"
              "SUPER+SHIFT,u,tagtoleft"
              "SUPER+SHIFT,i,tagtoright"

              # Window management
              "SUPER+SHIFT,Q,quit"
              "SUPER,Escape,spawn,lock-screen"
              "SUPER+CTRL,Return,spawn,alacritty --class float"
              "SUPER,W,killclient"
              "SUPER,g,togglefloating"
              "SUPER,F,togglemaximizescreen"
              "SUPER+CTRL,F,togglefullscreen"
              "SUPER,t,switch_layout"
              "SUPER,R,switch_proportion_preset"
              "SUPER,Minus,set_proportion,0.5"
              "SUPER,Equal,set_proportion,1.0"
              "SUPER,comma,scroller_stack,left"
              "SUPER,period,scroller_stack,right"

              # Focus / movement
              "SUPER,h,focusdir,left"
              "SUPER,l,focusdir,right"
              "SUPER,k,focusstack,prev"
              "SUPER,j,focusstack,next"
              "SUPER+SHIFT,h,exchange_client,left"
              "SUPER+SHIFT,l,exchange_client,right"
              "SUPER+SHIFT,k,exchange_stack_client,prev"
              "SUPER+SHIFT,j,exchange_stack_client,next"

              # Screenshots
              "NONE,Print,spawn_shell,grim - | wl-copy -t image/png"
              "SHIFT,Print,spawn_shell,grim -g \"$(slurp)\" | wl-copy -t image/png"
              "SUPER,A,spawn_shell,grim -g \"$(slurp)\" -t png /tmp/satty.png && satty --filename /tmp/satty.png --initial-tool arrow --copy-command \"wl-copy -t image/png\" --output-filename /tmp/satty.png"

              # Recorder / color picker / logout
              "SUPER+SHIFT,R,spawn_shell,if pgrep -x wf-recorder >/dev/null; then pkill -x wf-recorder; else mkdir -p \"$HOME/Videos\" && wf-recorder -g \"$(slurp)\" -f \"$HOME/Videos/recording-$(date +%Y-%m-%d_%H-%M-%S).mp4\" & fi"
              "SUPER+SHIFT,P,spawn_shell,hex=$(hyprpicker -f hex -n -a); [ -n \"$hex\" ] && notify-send \"Picked color: $hex\""
              "SUPER+SHIFT,W,spawn,wlogout"

              # Media keys
              "NONE,XF86AudioLowerVolume,spawn,wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
              "NONE,XF86AudioRaiseVolume,spawn,wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"
              "NONE,XF86AudioMute,spawn,wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
              "NONE,XF86AudioPlay,spawn,playerctl play-pause"
              "NONE,XF86AudioNext,spawn,playerctl next"
              "NONE,XF86AudioPrev,spawn,playerctl previous"
              "NONE,XF86MonBrightnessDown,spawn,brightnessctl set 5%-"
              "NONE,XF86MonBrightnessUp,spawn,brightnessctl set 5%+"
            ];
          };
        };
      };
  };
}
