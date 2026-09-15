{ config, lib, pkgs, ... }: {
  imports = [ ./hardware-configuration.nix ];
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nixos-btw";
  networking.networkmanager.enable = true;

  time.timeZone = "America/Los_Angeles";
  programs.zsh.enable = true;
  programs.dconf.enable = true;
  environment.sessionVariables.TERMINAL = "st";
  services.displayManager.ly.enable = true;
  services.xserver = {
    enable = true;
    autoRepeatDelay = 200;
    autoRepeatInterval = 35;
    # windowManager.qtile.enable = true;
    windowManager.oxwm.enable = true;
    displayManager.sessionCommands = ''
      ${pkgs.xwallpaper}/bin/xwallpaper --zoom /home/grae/nix/walls/wall1.png
    '';
    extraConfig = ''
      	Section "Monitor"
      	  Identifier "Virtual-1"
      	  Option "PreferredMode" "1920x1080"
      	EndSection
    '';
  };

  services.picom.enable = true;

  # Stop systemd-gpt-auto-generator from using /dev/sda2 as swap
  # (no valid swap filesystem is set up on this VM disk).
  systemd.generators.systemd-gpt-auto-generator = "/dev/null";

  users.users.grae = {
    isNormalUser = true;
    initialPassword = "qwe";
    shell = pkgs.zsh;
    extraGroups = [ "wheel" ];
    packages = with pkgs; [
      tree
    ];
  };

  environment.systemPackages = with pkgs; [
    qutebrowser
    vim
    wget
    git
    lazygit
    tmux
    starship
  ];

  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
  ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  system.stateVersion = "25.05";
}

