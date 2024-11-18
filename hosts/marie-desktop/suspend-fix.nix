{ pkgs, lib, ... }:
{
  systemd.services.fix-suspend = {
    description = "Fix suspend crash";
    unitConfig.Type = "oneshot";
    serviceConfig = {
      ExecStart = lib.concatStringsSep " " [
        (lib.getExe pkgs.bash)
        "-c"
        (lib.escapeShellArg "echo GPP0 > /proc/acpi/wakeup")
      ];
      RemainAfterExit = true;
    };
    wantedBy = [ "multi-user.target" ];
  };
}
