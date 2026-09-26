# Throwaway bootstrap system, used only to install a minimal machine that can
# then apply the real configuration. See README.md step 4.
#
# Why this exists: the install ISO has no nixos-rebuild, so something has to be
# installed before ~/nix#nixos-btw can be built. This is that something. It is
# NOT the config you end up running - it is replaced wholesale in step 5.
#
# Self-contained on purpose: no <nixpkgs/...> channel imports, so it evaluates
# against exactly the nixpkgs pinned in flake.lock.
{ config, lib, modulesPath, ... }:
{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  # FileSystems come from ./disko.nix, which the flake imports alongside this.

  # MUST match the real config, or the machine will not boot after install.
  # nixos-install runs `switch-to-configuration boot`, which installs whichever
  # bootloader this selects. Omitting these leaves you unbootable.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Same values the old hardware-configuration.nix carried, so the installed
  # kernel can see this machine's hardware.
  boot.initrd.availableKernelModules = [
    "xhci_pci"
    "ahci"
    "uas"
    "sd_mod"
    "rtsx_pci_sdmmc"
  ];
  hardware.enableRedistributableFirmware = true;
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  # Required for step 5, which clones the repo over the network and then runs
  # nixos-rebuild as a normal user.
  networking.networkmanager.enable = true;
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
  # mkAfter keeps the built-in "root" entry instead of duplicating it.
  nix.settings.trusted-users = lib.mkAfter [ "grae" ];

  users.users.grae = {
    isNormalUser = true;
    initialPassword = "qwe";
    extraGroups = [ "wheel" ];
  };

  # Keep the bootstrap build small; it is thrown away moments later.
  documentation.enable = false;

  system.stateVersion = "25.05";
}
