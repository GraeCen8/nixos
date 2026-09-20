{ config, lib, pkgs, ... }: {
  imports = [ ./hardware-configuration.nix ];
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nixos-btw";
  networking.networkmanager.enable = true;

  services.upower.enable = true;
  services.power-profiles-daemon.enable = true;

  time.timeZone = "Europe/London";
  programs.zsh.enable = true;
  programs.dconf.enable = true;
  environment.sessionVariables.TERMINAL = "st";
  services.displayManager.ly.enable = true;
  # Wayland setup; X11 and compositors removed
  programs.niri.enable = true;
  services.xserver.enable = false;
  # If you want a wallpaper, use swaybg/hyprpaper under Wayland or launch from niri exec commands.

  # Helium browser (Chromium-based) via oxcl/nix-flake-helium-browser.
  # Provides pkgs.helium + programs.helium (flags/policies).
  # Startpage lives at ~/.config/helium/startpage.html (from ./config/helium/).
  programs.helium = {
    enable = true;
    flags = [
      "--ozone-platform-hint=auto"
    ];
    policies = {
      HomepageLocation = "file:///home/grae/.config/helium/startpage.html";
      HomepageIsNewTabPage = true;
      RestoreOnStartup = 4;
      RestoreOnStartupURLs = [ "file:///home/grae/.config/helium/startpage.html" ];
      ExtensionInstallForcelist = [
        # Vimium (keyboard navigation)
        "dbepggeogbaibhgnhhndojpepiihcmeb;https://clients2.google.com/service/update2/crx"
        # Rose Pine (base) Chrome theme
        "noimedcjdohhokijigpfcbjcfcaaahej;https://clients2.google.com/service/update2/crx"
      ];
    };
  };

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
    # Core utilities
    wget
    git
    vim
    tmux
    # System/Tools
    lazygit
    btop
    fastfetch
    starship
    # File Managers
    pcmanfm
    # Applications
    # (helium is installed via programs.helium.enable above)
  ];

  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
  ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  system.stateVersion = "25.05";
}

