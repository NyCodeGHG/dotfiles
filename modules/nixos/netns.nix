{
  lib,
  pkgs,
  ...
}:
{
  systemd.services."netns@" = {
    description = "%I network namespace";
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${lib.getExe' pkgs.iproute2 "ip"} netns add %I";
      ExecStop = "${lib.getExe' pkgs.iproute2 "ip"} netns delete %I";
    };
  };

  systemd.targets."netns@" = {
    description = "%I network namespace target";
    after = [ "netns@%I.service" ];
    wants = [ "netns@%I.service" ];
  };
}
