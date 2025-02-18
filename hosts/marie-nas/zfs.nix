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
      ExecStart = "${lib.getExe pkgs.hd-idle} -i 1200";
      DynamicUser = true;
      SupplementaryGroups = [ "disk" ];
      ProtectSystem = "strict";
      ProtectHome = true;
    };
  };
}
