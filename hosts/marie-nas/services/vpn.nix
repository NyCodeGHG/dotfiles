{ pkgs, lib, ... }:
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

  systemd.services.setup-netns-vpn = {
    after = [ "netns@vpn.service" ];
    bindsTo = [ "netns@vpn.service" ];
    description = "Setup VPN Network Namespace";
    serviceConfig = {
      RemainAfterExit = true;
      Type = "oneshot";
    };
    path = with pkgs; [
      iproute2
      wireguard-tools
    ];

    script = ''
      set -euo pipefail

      ip -netns vpn link set lo up
    '';
  };
}
