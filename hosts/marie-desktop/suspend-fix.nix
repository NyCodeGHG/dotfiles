{ pkgs, lib, ... }:
{
  systemd.services.fix-suspend = {
    description = "Fix suspend crash";
    unitConfig.Type = "oneshot";
    before = [
      "systemd-suspend.service"
      "systemd-hibernate.service"
      "systemd-hybrid-sleep.service"
      "systemd-suspend-then-hibernate.service"
    ];
    serviceConfig = {
      ExecStart = lib.concatStringsSep " " [
        (lib.getExe pkgs.bash)
        "-c"
        (lib.escapeShellArg "echo GPP0 > /proc/acpi/wakeup && echo GPP8 > /proc/acpi/wakeup")
      ];
    };
    wantedBy = [
      "sleep.target"
      "multi-user.target"
    ];
  };
}
