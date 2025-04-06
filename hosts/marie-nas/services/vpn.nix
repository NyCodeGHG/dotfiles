{ pkgs, lib, config, ... }:
let
  firewall = pkgs.writeText "rules.nft" ''
    flush ruleset

    table inet filter {
        set forwarded-ports {
            typeof udp dport
        }
        chain input {
            type filter hook input priority 0; policy drop;

            tcp dport @forwarded-ports accept
            udp dport @forwarded-ports accept

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

    systemd.services.vpn-portforward = {
      after = [ "netns@vpn.service" "transmission.service" ];
      description = "VPN Port forwarding";
      wantedBy = [ "transmission.service" ];
      bindsTo = [ "transmission.service" ];
      serviceConfig = {
        Type = "oneshot";
        NetworkNamespacePath = "/var/run/netns/vpn";
        LoadCredential = "transmission.json:${config.age.secrets.transmission.path}";
        CapabilityBoundingSet = "CAP_NET_ADMIN";
        AmbientCapabilities = "CAP_NET_ADMIN";
        DynamicUser = true;
      };
      path = with pkgs; [ 
        libnatpmp
        config.services.transmission.package
        nftables
        ripgrep
        jq
      ];
      script = ''
        UDP_PORT="$(natpmpc -a 1 0 udp -g 10.2.0.1 | rg -o 'Mapped public port (\d+) protocol' -r '$1')"
        TCP_PORT="$(natpmpc -a 1 0 tcp -g 10.2.0.1 | rg -o 'Mapped public port (\d+) protocol' -r '$1')"

        nft flush set inet filter forwarded-ports
        nft add element inet filter forwarded-ports { "$UDP_PORT" }

        if [[ "$TCP_PORT" != "$UDP_PORT" ]]; then
          echo "Got a different port for TCP: $TCP_PORT"
          nft add element inet filter forwarded-ports { "$TCP_PORT" }
        fi
        
        TR_AUTH="transmission:$(jq -r '."rpc-password"' "$CREDENTIALS_DIRECTORY/transmission.json")" \
          transmission-remote --port "$UDP_PORT" --authenv
      '';
    };
    systemd.timers.vpn-portforward = {
      wantedBy = [ "transmission.service" ];
      bindsTo = [ "transmission.service" ];
      timerConfig = {
        OnUnitActiveSec = "50s";
      };
      unitConfig = {
        StopWhenUnneeded = true;
      };
    };
  };
}
