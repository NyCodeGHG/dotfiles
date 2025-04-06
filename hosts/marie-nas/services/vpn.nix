{ pkgs, lib, config, ... }:
let
  firewall = pkgs.writeText "rules.nft" ''
    flush ruleset

    table inet filter {
        chain input {
            type filter hook input priority 0; policy drop;

            # Allow traffic from established and related packets, drop invalid
            ct state vmap { established : accept, related : accept, invalid : drop }

            # Allow loopback traffic.
            iifname lo accept

            icmpv6 type { nd-neighbor-solicit, nd-router-advert, nd-neighbor-advert } accept
        }

        chain forward {
            type filter hook forward priority 0; policy drop;
        }
    }
  '';
in
{
  options.vpn.dns.resolvconf = lib.mkOption {
    type = lib.types.path;
    description = "resolv.conf file used for services in the vpn.";
    default = pkgs.writeText "resolv.conf" ''
      nameserver 9.9.9.9
    '';
  };
  config = {
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

    systemd.services.setup-netns-vpn = {
      after = [ "netns@vpn.service" ];
      bindsTo = [ "netns@vpn.service" ];
      wantedBy = [ "netns@vpn.target" ];
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

    systemd.services.nftables-vpn = {
      after = [ "netns@vpn.service" ];
      bindsTo = [ "netns@vpn.service" ];
      wantedBy = [ "netns@vpn.target" ];
      description = "Setup VPN Network Namespace firewall";
      serviceConfig = {
        RemainAfterExit = true;
        Type = "oneshot";
        ExecStart = "${lib.getExe pkgs.nftables} -f ${firewall}";
        NetworkNamespacePath = "/var/run/netns/vpn";
      };
      path = with pkgs; [ nftables ];
    };
  };
}
