{ config, ... }:
{
  boot = {
    initrd.kernelModules = [ "usb_storage" "e1000e" ]; 
    initrd.luks.devices = {
      root = {
        allowDiscards = true;
        device = "/dev/disk/by-partlabel/disk-boot-luks";
        keyFile = "/encryption-keys/root.key";
      };
      wd-red-plus-a = {
        allowDiscards = true;
        device = "/dev/disk/by-id/ata-WDC_WD120EFBX-68B0EN0_D7JPDSJN";
        keyFile = "/encryption-keys/wd-red-plus-a.key";
      };
      wd-red-plus-b = {
        allowDiscards = true;
        device = "/dev/disk/by-id/ata-WDC_WD120EFBX-68B0EN0_D7JLAHXN";
        keyFile = "/encryption-keys/wd-red-plus-b.key";
      };
    };
  };
  fileSystems = {
    "/" = {
      device = "zroot/local/root";
      fsType = "zfs";
      neededForBoot = true;
    };
    "/boot" = {
      device = "/dev/disk/by-partlabel/disk-boot-esp";
      fsType = "vfat";
      options = [ "umask=0077" ];
    };
    "/nix" = {
      device = "zroot/local/nix";
      fsType = "zfs";
      neededForBoot = true;
    };
    "/srv/shares" = {
      device = "tank/data/shares";
      fsType = "zfs";
    };
    "/srv/shares/marie" = {
      device = "tank/data/shares/marie";
      fsType = "zfs";
    };
    "/srv/shares/media" = {
      device = "tank/data/shares/media";
      fsType = "zfs";
    };
    "/state" = {
      device = "zroot/data/state";
      fsType = "zfs";
      neededForBoot = true;
    };
  };
  swapDevices = [
    {
      device = "/dev/disk/by-partlabel/disk-boot-swap";
      randomEncryption = {
        allowDiscards = false;
        enable = true;
      };
    }
  ];
  boot.initrd.supportedFilesystems.ext4 = true;
  boot.initrd.systemd = {
    enable = true;
    contents."/etc/fstab".text = ''
      UUID=a92d7fc5-21a0-4e7a-b995-2fb84195c2f1 /encryption-keys ext4 ro
    '';
  };
}
