{
  pkgs,
  lib,
  config,
  ...
}:
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
  imports = [
    ../../../../modules/nixos/netns.nix
  ];
  options.vpn.dns.resolvconf = lib.mkOption {
    type = lib.types.path;
    description = "resolv.conf file used for services in the vpn.";
    default = pkgs.writeText "resolv.conf" ''
      nameserver 2a07:b944::2:1
      nameserver 10.2.0.1
    '';
  };
  config = {
    systemd.services.setup-netns-vpn = {
      after = [ "netns@vpn.service" ];
      partOf = [ "netns@vpn.service" ];
      wantedBy = [ "netns@vpn.target" ];
      restartTriggers = [ config.age.secrets.vpn-wg.file ];
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
        ip -n vpn addr add 2a07:b944::2:2/128 dev vpn
        ip -n vpn addr add 10.2.0.2/32 dev vpn
        ip netns exec vpn wg syncconf vpn <(wg-quick strip "$CREDENTIALS_DIRECTORY/vpn-wg.conf")
        ip -n vpn link set vpn up
        ip -6 -n vpn route add default dev vpn
        ip -n vpn route add default dev vpn
      '';
    };

    age.secrets.vpn-wg.file = ../../secrets/vpn-wg.age;

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
      after = [
        "netns@vpn.service"
        "transmission.service"
      ];
      description = "VPN Port forwarding";
      wantedBy = [ "transmission.service" ];
      partOf = [ "transmission.service" ];
      requisite = [ "transmission.service" ];
      serviceConfig = {
        Type = "exec";
        NetworkNamespacePath = "/var/run/netns/vpn";
        LoadCredential = "transmission.json:${config.age.secrets.transmission.path}";
        CapabilityBoundingSet = "CAP_NET_ADMIN";
        AmbientCapabilities = "CAP_NET_ADMIN";
        DynamicUser = true;
        Restart = "on-failure";
        RestartSec = "1s";
        WatchdogSec = "60";
        NotifyAccess = "all";
      };
      path = with pkgs; [
        libnatpmp
        config.services.transmission.package
        nftables
        ripgrep
        jq
      ];
      script = ''
        function cleanup() {
          nft flush set inet filter forwarded-ports
          if [[ -n "$PORT" ]]; then
            natpmpc -a "$PORT" "$PORT" udp 0 -g 10.2.0.1 || :
          fi
        }

        trap cleanup EXIT
        systemd-notify WATCHDOG=1

        while :
        do
          PORT="$(natpmpc -a 1 0 udp 60 -g 10.2.0.1 | rg -o 'Mapped public port (\d+) protocol' -r '$1')"
          TCP_PORT="$(natpmpc -a "$PORT" "$PORT" tcp 60 -g 10.2.0.1 | rg -o 'Mapped public port (\d+) protocol' -r '$1')"

          if [[ "$PORT" != "$TCP_PORT" ]]; then
            echo "Got different TCP and UDP ports." | systemd-cat --priority warning --identifier "vpn-portforward"
          fi

          nft flush set inet filter forwarded-ports
          nft add element inet filter forwarded-ports { "$PORT" }

          TR_AUTH="transmission:$(jq -r '."rpc-password"' "$CREDENTIALS_DIRECTORY/transmission.json")" \
            transmission-remote --port "$PORT" --authenv

          systemd-notify --status "Forwarded port $PORT (udp) and $TCP_PORT (tcp) for transmission"
          systemd-notify WATCHDOG=1

          sleep 45
        done
      '';
    };
  };
}
