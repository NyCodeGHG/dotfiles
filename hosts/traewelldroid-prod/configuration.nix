{ modulesPath, ... }:
{
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
    ./networking.nix
  ];

  uwumarie.profiles = {
    headless = true;
  };

  # Disable "experimental" default stuff
  security.sudo-rs.enable = false;

  uwumarie.profiles = {
    locale = false;
    ntp = false;
    zram = false;
    users.marie = true;
  };

  systemd = {
    enableEmergencyMode = false;
    watchdog.runtimeTime = "15s";
  };

  system.stateVersion = "25.05";

  boot.loader.limine = {
    enable = true;
    biosSupport = true;
    biosDevice = "/dev/disk/by-id/scsi-0QEMU_QEMU_HARDDISK_64010534";
    maxGenerations = 5;
  };

  boot.initrd.availableKernelModules = [
    "ahci"
    "xhci_pci"
    "virtio_pci"
    "virtio_scsi"
    "sd_mod"
    "sr_mod"
  ];

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/b5e9bf72-8517-4094-89f4-041b80fbaf20";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/F671-CAFF";
    fsType = "vfat";
    options = [
      "fmask=0077"
      "dmask=0077"
    ];
  };

  swapDevices = [
    {
      device = "/dev/disk/by-id/scsi-0QEMU_QEMU_HARDDISK_64010534-part3";
      randomEncryption.enable = true;
    }
  ];

  nixpkgs.hostPlatform = "x86_64-linux";
}
