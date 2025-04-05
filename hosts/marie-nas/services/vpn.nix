{ pkgs, lib, config, ... }:
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
      LoadCredential = "vpn-wg.conf:${config.age.secrets.vpn-wg.path}";
    };
    path = with pkgs; [
      iproute2
      wireguard-tools
    ];

    script = ''
      set -euo pipefail

      ip -netns vpn link set lo up

      # setup wireguard interface
      ip link add vpn type wireguard
      ip -n vpn link del vpn || :
      ip link set vpn netns vpn
      ip -n vpn addr add 10.2.0.2/32 dev vpn
      ip netns exec vpn wg syncconf vpn <(wg-quick strip "$CREDENTIALS_DIRECTORY/vpn-wg.conf")
      ip -n vpn link set vpn up
      ip -n vpn route add default dev vpn
    '';
  };

  age.secrets.vpn-wg.file = ../secrets/vpn-wg.age;
}
