{ config, lib, pkgs, ... }:
let
  # Keep in sync with `hosts` in flake.nix when adding a machine.
  username = "grae";
in
{
  # Filesystems come from ./disko.nix. Bootloader setup is below.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.initrd.availableKernelModules = [
    "xhci_pci"
    "ahci"
    "uas"
    "sd_mod"
    "rtsx_pci_sdmmc"
  ];
  boot.initrd.kernelModules = [ "dm-snapshot" ];

  networking.hostName = "nixos-btw";
  networking.networkmanager.enable = true;
  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  services.upower.enable = true;
  services.power-profiles-daemon.enable = true;

  # upower sees no battery/AC on this machine, so PPD parks in
  # power-saver (900MHz on this i7-7500U) and everything feels slow.
  # Force balanced at boot; change live with `powerprofilesctl set <profile>`.
  systemd.services.set-balanced-power-profile = {
    description = "Set balanced power profile (PPD defaults to power-saver here)";
    wantedBy = [ "multi-user.target" ];
    after = [ "power-profiles-daemon.service" ];
    serviceConfig.Type = "oneshot";
    script = "${pkgs.power-profiles-daemon}/bin/powerprofilesctl set balanced";
  };

  # No swap partition + Chromium-class browser = stalls under memory
  # pressure. Compressed RAM swap is the standard NixOS answer.
  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 50;
  };

  time.timeZone = "Europe/London";
  programs.zsh.enable = true;
  programs.dconf.enable = true;
  environment.sessionVariables.TERMINAL = "footclient";
  services.displayManager.ly.enable = true;
  # Wayland setup; X11 and compositors removed
  programs.niri.enable = true;
  services.xserver.enable = false;
  # If you want a wallpaper, use swaybg/hyprpaper under Wayland or launch from niri exec commands.

  # Needed on a fresh install: without this the very first `nixos-rebuild` as
  # a normal user cannot write to /nix and silently falls back to building
  # everything as root. mkAfter keeps the default "root" entry.
  nix.settings.trusted-users = lib.mkAfter [ username ];

  # Helium browser (Chromium-based) via oxcl/nix-flake-helium-browser.
  # Provides pkgs.helium + programs.helium (flags/policies).
  # Startpage lives at ~/.config/helium/startpage.html (from ./config/helium/).
  programs.helium = {
    enable = true;
    flags = [
      "--ozone-platform-hint=auto"
    ];
    policies = {
      HomepageLocation = "file:///home/${username}/.config/helium/startpage.html";
      HomepageIsNewTabPage = true;
      RestoreOnStartup = 4;
      RestoreOnStartupURLs = [ "file:///home/${username}/.config/helium/startpage.html" ];
      # NOTE: no ExtensionInstallForcelist on purpose. Helium neuters
      # Google's extension update service (requests get sinkholed to
      # helium-services-are-disabled.qjz9zk), so force-installed
      # extensions fail with "no_update_info" and never install
      # (verified in chrome logs). Extensions are pre-installed
      # declaratively from pinned local .crx files instead, see
      # home.nix (vimiumCrx / rosePineCrx + External Extensions JSONs).
    };
  };

  # Stop systemd-gpt-auto-generator from using /dev/sda2 as swap
  # (no valid swap filesystem is set up on this VM disk).
  systemd.generators.systemd-gpt-auto-generator = "/dev/null";

  # TODO: change this. It is committed in plaintext, so treat it as public.
  users.users.${username} = {
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
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  # Was in the old hardware-configuration.nix; needed for Wi-Fi and the
  # i7-7500U's microcode.
  hardware.enableRedistributableFirmware = lib.mkDefault true;
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  system.stateVersion = "25.05";
}

