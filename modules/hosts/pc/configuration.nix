{
  self,
  inputs,
  ...
}:
{
  flake.nixosModules.pcConfig =
    {
      config,
      pkgs,
      ...
    }:
    {
      imports = [
        self.nixosModules.pcHardware
        self.nixosModules.desktop
        self.nixosModules.settings
        self.nixosModules.gaming
        self.nixosModules.nvidia
      ];

      hardware.gpu.nvidia = true;
      hardware.gpu.nvidiaOutput = "DP-3";

      hardware.graphics.enable = true;

      # KTMicro KT USB Audio only supports S16_LE; PipeWire fails with
      # "set_hw_params: No space left on device" when probing other formats.
      # High priority.session keeps the headset as the default sink when plugged in.
      services.pipewire.wireplumber.extraConfig."51-ktmicro".monitor.alsa.rules = [
        {
          matches = [
            { "node.name" = "~alsa_output.usb-KTMicro_KT_USB_Audio_*"; }
            { "node.name" = "~alsa_input.usb-KTMicro_KT_USB_Audio_*"; }
          ];
          actions = {
            "update-props" = {
              "api.alsa.format" = [ "S16LE" ];
              "api.alsa.rate" = [ 48000 ];
              "audio.format" = "S16LE";
              "audio.rate" = 48000;
              "priority.session" = [ 5000 ];
            };
          };
        }
      ];

      # Disable if low on RAM
      boot.tmp.useTmpfs = true;

      networking.hostName = "nixos-pc";
      user.name = "grae";
      user.fullName = "grae ceney";

      environment.sessionVariables.XCURSOR_SIZE = "20";
      system.theme.name = "catppuccin-mocha"; # "catppuccin-mocha" "nord" "minimalist" "tokyo-night" "rose-pine"
      system.theme.uiScale = 1.0; # 1920px primary monitor / 1920 reference
      programs.nvim.profile = "full"; # "full" (NvChad) or "minimal" (lazy.nvim)

      services.flatpak.enable = true;

      system.stateVersion = "26.05"; # dont change
    };
}
