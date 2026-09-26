# Declarative disk layout. Replaces the old hardware-configuration.nix, which
# pinned the previous install's disk UUIDs and so could not be reused on a
# freshly wiped disk.
#
# This module only *describes* the layout. Nothing is written unless you run
# nixos-disks explicitly, so importing it is safe on a machine you care about.
{ ... }:
{
  disko.devices.disk.main = {
    type = "disk";

    # Change this if your disk is not /dev/sda. nixos-disks has no flag to
    # override the device, so this line is the single source of truth.
    # DESTRUCTIVE: nixos-disks wipes whatever is named here.
    device = "/dev/sda";

    content = {
      type = "gpt";
      partitions = {
        # EFI System Partition, mounted at /boot for systemd-boot.
        boot = {
          size = "700M";
          type = "EF00";
          label = "nixos-boot";
          content = {
            type = "filesystem";
            format = "vfat";
            mountpoint = "/boot";
            mountOptions = [
              "fmask=0022"
              "dmask=0022"
            ];
          };
        };
        root = {
          size = "100%";
          label = "nixos";
          content = {
            type = "filesystem";
            format = "ext4";
            mountpoint = "/";
          };
        };
      };
    };
  };

  # No swap partition on this machine; zramSwap in configuration.nix
  # provides compressed RAM swap instead.
  swapDevices = [ ];
}
