{ pkgs, lib, ... }:
{
  networking.hostId = "5b001dfe";
  boot = {
    supportedFilesystems.zfs = true;
    zfs.forceImportRoot = false;
  };

  systemd.services.hd-idle = {
    description = "Spin down disks";
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "simple";
      ExecStart = lib.concatStringsSep " " [
        (lib.getExe pkgs.hd-idle)
        "-i 0"
        "-c ata"
        "-a /dev/disk/by-id/ata-WDC_WD120EFBX-68B0EN0_D7JPDSJN"
        "-i 1800"
        "-a /dev/disk/by-id/ata-WDC_WD120EFBX-68B0EN0_D7JLAHXN"
        "-i 1800"
      ];
      ProtectSystem = "strict";
      ProtectHome = true;
    };
  };

  services.sanoid = {
    enable = true;
    datasets = {
      "zroot/data" = {
        recursive = "zfs";
        hourly = 36;
        daily = 30;
        monthly = 3;
      };
    };
  };

  services.syncoid = {
    enable = true;
    interval = "weekly";
    commands.zroot = {
      target = "tank/zroot-data";
      source = "zroot/data";
      recursive = true;
    };
  };
}
