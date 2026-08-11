{
  self,
  inputs,
  ...
}: {
  flake.nixosModules.lock = {
    pkgs,
    lib,
    config,
    ...
  }: let
    themes = import ../../themes-data.nix;
    theme = themes.${config.system.theme.name};
    c = theme.colors;

    hexDigit = ch: let
      o = lib.strings.charToInt ch;
    in
      if o >= 48 && o <= 57 then o - 48
      else if o >= 65 && o <= 70 then o - 55
      else if o >= 97 && o <= 102 then o - 87
      else throw "invalid hex digit: ${ch}";

    hexToInt = str: let
      chars = lib.strings.stringToCharacters str;
    in (hexDigit (builtins.elemAt chars 0)) * 16 + (hexDigit (builtins.elemAt chars 1));

    toRgba = hex: alpha: let
      h = lib.removePrefix "#" hex;
      r = hexToInt (lib.substring 0 2 h);
      g = hexToInt (lib.substring 2 2 h);
      b = hexToInt (lib.substring 4 2 h);
    in "rgba(${toString r}, ${toString g}, ${toString b}, ${toString alpha})";

    hyprlockConf = pkgs.writeText "hyprlock.conf" ''
      general {
          fractional_scaling = 2
          screencopy_mode = 1
      }

      background {
          monitor =
          path = screenshot
          color = rgb(0,0,0)

          blur_size = 6
          blur_passes = 3
          noise = 0.0117
          contrast = 1.3000
          brightness = 0.6000
          vibrancy = 0.2100
          vibrancy_darkness = 0.0
      }

      # Hours
      label {
          monitor =
          text = cmd[update:1000] echo "<b><big> $(date +"%H") </big></b>"
          color = ${toRgba c.fg 1.0}
          font_size = 112
          font_family = "${themes.font.family}"
          shadow_passes = 0
          shadow_size = 0

          position = 0, 220
          halign = center
          valign = center
      }

      # Minutes
      label {
          monitor =
          text = cmd[update:1000] echo "<b><big> $(date +"%M") </big></b>"
          color = ${toRgba c.fg 1.0}
          font_size = 112
          font_family = "${themes.font.family}"
          shadow_passes = 0
          shadow_size = 0

          position = 0, 80
          halign = center
          valign = center
      }

      # Day
      label {
          monitor =
          text = cmd[update:18000000] echo "<b><big> $(date +'%A') </big></b>"
          color = ${toRgba c.fg-dim 1.0}
          font_size = 18
          font_family = "${themes.font.family}"

          position = 0, -15
          halign = center
          valign = center
      }

      # Date
      label {
          monitor =
          text = cmd[update:18000000] echo "<b> $(date +'%d %b') </b>"
          color = ${toRgba c.fg-dim 1.0}
          font_size = 14
          font_family = "${themes.font.family}"

          position = 0, -40
          halign = center
          valign = center
      }

      input-field {
          monitor =
          size = 250, 50
          outline_thickness = 3

          dots_size = 0.26
          dots_spacing = 0.64
          dots_center = true
          dots_rounding = -1

          rounding = 22
          outer_color = ${toRgba c.accent 1.0}
          inner_color = ${toRgba c.bg-alt 0.5}
          font_color = ${toRgba c.fg 1.0}
          check_color = ${toRgba c.success 1.0}
          fail_color = ${toRgba c.error 1.0}
          capslock_color = ${toRgba c.warning 1.0}
          fade_on_empty = true
          placeholder_text = <i>Password...</i>
          fail_text = <i>Invalid Password!</i>
          check_text = <i>✓</i>

          position = 0, 120
          halign = center
          valign = bottom
      }
    '';

    lockScript = pkgs.writeShellScriptBin "lock-screen" ''
      exec ${pkgs.hyprlock}/bin/hyprlock
    '';
  in {
    security.pam.services.hyprlock = {};

    environment.systemPackages = [
      pkgs.hyprlock
      lockScript
    ];

    environment.etc."xdg/hypr/hyprlock.conf".source = hyprlockConf;

    systemd.services.lock-on-suspend = {
      enable = true;
      description = "Lock screen on suspend";
      before = ["sleep.target"];
      wantedBy = ["sleep.target"];
      environment = {
        WAYLAND_DISPLAY = "wayland-1";
        DISPLAY = ":0";
        XDG_RUNTIME_DIR = "/run/user/1000";
      };
      serviceConfig = {
        Type = "oneshot";
        User = config.user.name;
      };
      script = "${lockScript}/bin/lock-screen";
    };
  };
}
