{ self, inputs, ... }: {
  flake.nixosModules.waybar = { pkgs, lib, config, ... }:
  let
    themes = import ../../../themes-data.nix;
    theme = themes.${config.system.theme.name};
    c = theme.colors;

    waybarRaw = pkgs.waybar.overrideAttrs (old: {
      version = "0.15.0";
      src = pkgs.fetchFromGitHub {
        owner = "Alexays";
        repo = "Waybar";
        rev = "084d87401d0a91182c16aa7e5f674a7dde767185";
        hash = "sha256-POvwObPOp6O14n6KYWNLp2Y3paunA5f8U1NCaodNFcc=";
      };
      mesonFlags = old.mesonFlags ++ [
        "-Dcava=disabled"
        "-Dmango=true"
        "-Dwwan=disabled"
      ];
    });

    waybarMango = pkgs.runCommand "waybar" {
      meta.mainProgram = "waybar";
    } ''
      mkdir -p $out/bin
      cat > $out/bin/waybar <<WRAPPER
      #!${pkgs.runtimeShell}
      exec ${myWaybar}/bin/my-waybar
      WRAPPER
      chmod +x $out/bin/waybar
      ln -s ${waybarRaw}/bin/waybar $out/bin/waybar-raw
    '';

    mediaScripts = pkgs.stdenv.mkDerivation {
      name = "waybar-media-scripts";
      src = ./media;
      installPhase = ''
        mkdir -p $out
        cp *.sh $out/
        chmod +x $out/*.sh
      '';
    };

    waybarConfig = pkgs.writeText "config.jsonc" (builtins.replaceStrings
      [ "@mediaScripts@" ]
      [ "${mediaScripts}" ]
      (builtins.readFile ./config.jsonc)
    );

    waybarStyle = pkgs.writeText "style.css" ''
      @define-color highlight ${c.accent};
      @define-color dark-9 ${c.bg};
      @define-color dark-8 ${c.bg-alt};
      @define-color dark-7 ${c.bg-light};
      @define-color dark-6 ${c.bg-lighter};
      @define-color dark-5 ${c.info};

      * {
        font-family: ${themes.font.family} Propo;
        font-size: 11px;
      }

      window#waybar {
        background-color: transparent;
        color: ${c.fg};
      }

      window#waybar > box {
        background: @dark-9;
        border: 1px solid ${c.border};
        border-top: none;
        border-radius: 0 0 12px 12px;
        padding: 5px 12px;
        margin: 0 0 4px 0;
      }

      .modules-left,
      .modules-center,
      .modules-right {
        background: transparent;
        border: none;
        border-radius: 0;
        margin: 0;
        padding: 0;
      }

      #workspaces button {
        padding: 0px;
        margin: 0px 0px 0px 2px;
        background: transparent;
        border-radius: 2px;
        color: ${c.fg};
      }

      #workspaces button.active {
        background: @highlight;
        color: ${c.bg};
        font-weight: 700;
        border-radius: 12px;
      }

      #workspaces button.hidden {
        color: ${c.bg-lighter};
      }

      #submap,
      #battery,
      #bluetooth,
      #network,
      #cpu,
      #memory,
      #volume {
        border-radius: 3px;
        padding: 0px 3px;
        margin: 0px 2px 0px 0px;
      }

      #submap,
      #workspaces button.urgent {
        background: ${c.error};
        color: ${c.bg};
      }

      #pulseaudio-slider {
        padding: 0px;
        margin: 0px;
        margin-left: 2px;
      }

      #pulseaudio-slider slider {
        all: unset;
        min-height: 0;
        min-width: 0;
        opacity: 0;
        background-image: none;
        border: none;
        box-shadow: none;
      }

      #pulseaudio-slider trough {
        min-height: 5px;
        min-width: 40px;
        border-radius: 3px;
        background: @dark-7;
      }

      #pulseaudio-slider highlight {
        min-width: 5px;
        border-radius: 3px;
        background: @highlight;
      }

      #media {
        color: ${c.success};
        margin: 0px 0px 0px 6px;
      }

      #custom-media-animation {
        font-size: 9px;
        margin-right: 4px;
      }

      #custom-media-now-playing {
        margin-right: 4px;
      }

      #custom-media-time {
        color: @dark-5;
        font-size: 9px;
      }

      tooltip {
        background: @dark-9;
        border-radius: 5px;
      }

      tooltip label {
        color: ${c.fg};
      }
    '';

    islandFraction = builtins.toJSON config.programs.waybar.islandWidthFraction;
    referenceWidth = builtins.toString config.programs.waybar.referenceWidth;
    bottomGap = builtins.toString config.programs.waybar.bottomGap;

    myWaybar = pkgs.writeShellScriptBin "my-waybar" ''
      set -u

      FRACTION=${islandFraction}
      REFERENCE=${referenceWidth}
      BOTTOM_GAP=${bottomGap}
      BASE_CONF=${waybarConfig}
      BASE_CSS=${waybarStyle}
      OUT_DIR="''${XDG_RUNTIME_DIR:-/tmp}"
      GEN_CONF="$OUT_DIR/waybar-config.jsonc"
      GEN_CSS="$OUT_DIR/waybar-style.css"

      outputs="$(mmsg get all-monitors 2>/dev/null || true)"
      if [ -z "$outputs" ]; then
        exec "${waybarRaw}/bin/waybar"
      fi

      primary="$(printf '%s' "$outputs" | "${pkgs.jq}/bin/jq" -r '.monitors[0].name' 2>/dev/null || true)"
      primary_w="$(printf '%s' "$outputs" | "${pkgs.jq}/bin/jq" -r '.monitors[0].width / .monitors[0].scale' 2>/dev/null || true)"

      if [ -z "$primary_w" ] || [ "$primary_w" = "null" ]; then
        exec "${waybarRaw}/bin/waybar"
      fi

      ui_scale="$(awk -v w="$primary_w" -v r="$REFERENCE" 'BEGIN { printf "%.2f", w / r }')"

      if ! printf '%s' "$outputs" | "${pkgs.jq}/bin/jq" --argjson frac "$FRACTION" --slurpfile base <(cat "$BASE_CONF") '
          [ .monitors[] | . as $m | ((($m.width / $m.scale) * (1 - $frac) / 2) | round) as $mr | $base[0] * { output: $m.name, margin: ("0 \($mr) 0 \($mr)") } ]
        ' > "$GEN_CONF" 2>/dev/null; then
        exec "${waybarRaw}/bin/waybar"
      fi

      font_size="$(awk -v s="$ui_scale" 'BEGIN { printf "%.0f", 11 * s }')"
      media_font="$(awk -v s="$ui_scale" 'BEGIN { printf "%.0f", 9 * s }')"
      pad_v="$(awk -v s="$ui_scale" 'BEGIN { printf "%.0f", 5 * s }')"
      pad_h="$(awk -v s="$ui_scale" 'BEGIN { printf "%.0f", 12 * s }')"
      radius="$(awk -v s="$ui_scale" 'BEGIN { printf "%.0f", 12 * s }')"
      bottom="$(awk -v s="$ui_scale" -v g="$BOTTOM_GAP" 'BEGIN { printf "%.0f", g * s }')"
      tooltip_r="$(awk -v s="$ui_scale" 'BEGIN { printf "%.0f", 5 * s }')"

      cat "$BASE_CSS" > "$GEN_CSS"
      cat >> "$GEN_CSS" <<EOF
      * { font-size: ''${font_size}px; }
      #custom-media-animation, #custom-media-time { font-size: ''${media_font}px; }
      window#waybar > box { padding: ''${pad_v}px ''${pad_h}px; border-radius: 0 0 ''${radius}px ''${radius}px; margin: 0 0 ''${bottom}px 0; }
      #workspaces button.active { border-radius: ''${radius}px; }
      tooltip { border-radius: ''${tooltip_r}px; }
      EOF

      exec "${waybarRaw}/bin/waybar" -c "$GEN_CONF" -s "$GEN_CSS"
    '';
  in {
    options.programs.waybar = {
      islandWidthFraction = lib.mkOption {
        type = lib.types.number;
        default = 0.70;
        description = "Fraction of the screen width that the bar island occupies";
      };

      referenceWidth = lib.mkOption {
        type = lib.types.int;
        default = 1920;
        description = "Logical width at which the UI scale is 1.0";
      };

      bottomGap = lib.mkOption {
        type = lib.types.number;
        default = 8;
        description = "Gap in px (at uiScale 1.0) between the bar's bottom edge and the windows below";
      };

      wrapper = lib.mkOption {
        type = lib.types.package;
        description = "Runtime-adaptive waybar wrapper that scales per monitor";
      };
    };

    config = {
      programs.waybar.wrapper = myWaybar;

      environment.systemPackages = with pkgs; [ waybarMango pavucontrol zscroll wifitui bluetui myWaybar ];
      environment.etc."xdg/waybar/config.jsonc".source = waybarConfig;
      environment.etc."xdg/waybar/style.css".source = waybarStyle;
    };
  };
}
