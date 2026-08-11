{
  self,
  inputs,
  ...
}: {
  flake.nixosModules.wlogout = {
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

    layout = pkgs.writeText "wlogout-layout" ''
      {
          "label" : "lock",
          "action" : "lock-screen",
          "text" : "Lock",
          "keybind" : "l"
      }
      {
          "label" : "reboot",
          "action" : "systemctl reboot",
          "text" : "Reboot",
          "keybind" : "r"
      }
      {
          "label" : "shutdown",
          "action" : "systemctl poweroff",
          "text" : "Shutdown",
          "keybind" : "s"
      }
      {
          "label" : "logout",
          "action" : "mmsg dispatch quit",
          "text" : "Logout",
          "keybind" : "e"
      }
      {
          "label" : "suspend",
          "action" : "systemctl suspend",
          "text" : "Suspend",
          "keybind" : "u"
      }
      {
          "label" : "hibernate",
          "action" : "systemctl hibernate",
          "text" : "Hibernate",
          "keybind" : "h"
      }
    '';

    style = pkgs.writeText "wlogout-style.css" ''
      * {
        background-image: none;
        box-shadow: none;
      }

      window {
        font-family: "${themes.font.family}";
        background-color: rgba(0, 0, 0, 0.45);
      }

      button {
        border-radius: 20px;
        margin: 10px;
        color: ${c.fg};
        border-width: 0px;
        background-color: ${toRgba c.bg-alt 0.5};
        background-repeat: no-repeat;
        background-position: center;
        background-size: 20%;
        font-size: 20px;
        outline-style: none;
      }

      button:hover, button:focus {
        background-color: ${toRgba c.accent 0.8};
        color: ${c.bg};
        background-size: 30%;
        transition: all 0.3s cubic-bezier(.55, 0.0, .28, 1.682);
      }

      #lock { background-image: image(url("./icons/lock.png")); }
      #reboot { background-image: image(url("./icons/restart.png")); }
      #shutdown { background-image: image(url("./icons/power.png")); }
      #logout { background-image: image(url("./icons/logout.png")); }
      #suspend { background-image: image(url("./icons/sleep.png")); }
      #hibernate { background-image: image(url("./icons/hibernate.png")); }
    '';
  in {
    environment.systemPackages = [
      pkgs.wlogout
    ];

    environment.etc."wlogout/layout".source = layout;
    environment.etc."wlogout/style.css".source = style;
    environment.etc."wlogout/icons".source = ./wlogout/icons;
  };
}
