{ pkgs, config, lib, ... }:
{
  imports = [
    ./nginx.nix
    ./peers
    ./peers/emma
    ./peers/kioubit
  ];
  systemd.network = {
    enable = true;
    networks = {
      "60-dn42" = {
        name = "dn42";
        addresses = [
          {
            addressConfig = {
              Address = "fdf1:3ba4:9723::1/128";
              Scope = "global";
            };
          }
        ];
      };
    };
    netdevs."60-dn42" = {
      netdevConfig = {
        Name = "dn42";
        Kind = "dummy";
      };
    };
  };

  services.bird2 = {
    enable = true;
    preCheckConfig = ''
      touch roa_dn42.conf roa_dn42_v6.conf
    '';
    config = ''
      define OWNAS =  4242423085;
      # define OWNIP =  <OWNIP>;
      define OWNIPv6 = fdf1:3ba4:9723::1;
      # define OWNNET = <OWNNET>;
      define OWNNETv6 = fdf1:3ba4:9723::/48;
      # define OWNNETSET = [<OWNNET>+];
      define OWNNETSETv6 = [fdf1:3ba4:9723::/48+];

      router id 89.58.10.36;

      protocol device {
          scan time 10;
      }

      /*
       *  Utility functions
       */

      # function is_self_net() {
      #   return net ~ OWNNETSET;
      # }

      function is_self_net_v6() {
        return net ~ OWNNETSETv6;
      }

      # function is_valid_network() {
      #   return net ~ [
      #     172.20.0.0/14{21,29}, # dn42
      #     172.20.0.0/24{28,32}, # dn42 Anycast
      #     172.21.0.0/24{28,32}, # dn42 Anycast
      #     172.22.0.0/24{28,32}, # dn42 Anycast
      #     172.23.0.0/24{28,32}, # dn42 Anycast
      #     172.31.0.0/16+,       # ChaosVPN
      #     10.100.0.0/14+,       # ChaosVPN
      #     10.127.0.0/16{16,32}, # neonetwork
      #     10.0.0.0/8{15,24}     # Freifunk.net
      #   ];
      # }

      # roa4 table dn42_roa;
      roa6 table dn42_roa_v6;

      # protocol static {
      #     roa4 { table dn42_roa; };
      #     include "roa_dn42.conf";
      # };

      protocol static {
          roa6 { table dn42_roa_v6; };
          include "roa_dn42_v6.conf";
      };

      function is_valid_network_v6() {
        return net ~ [
          fd00::/8{44,64} # ULA address space as per RFC 4193
        ];
      }

      protocol kernel {
          scan time 20;

          ipv6 {
              import none;
              export filter {
                  if source = RTS_STATIC then reject;
                  krt_prefsrc = OWNIPv6;
                  accept;
              };
          };
      };

      # protocol kernel {
      #     scan time 20;

      #     ipv4 {
      #         import none;
      #         export filter {
      #             if source = RTS_STATIC then reject;
      #             krt_prefsrc = OWNIP;
      #             accept;
      #         };
      #     };
      # }

      # protocol static {
      #     route OWNNET reject;

      #     ipv4 {
      #         import all;
      #         export none;
      #     };
      # }

      protocol static {
          route OWNNETv6 reject;

          ipv6 {
              import all;
              export none;
          };
      }

      template bgp dnpeers {
          local as OWNAS;
          path metric 1;

          # ipv4 {
          #     import filter {
          #       if is_valid_network() && !is_self_net() then {
          #         if (roa_check(dn42_roa, net, bgp_path.last) != ROA_VALID) then {
          #           print "[dn42] ROA check failed for ", net, " ASN ", bgp_path.last;
          #           reject;
          #         } else accept;
          #       } else reject;
          #     };

          #     export filter { if is_valid_network() && source ~ [RTS_STATIC, RTS_BGP] then accept; else reject; };
          #     import limit 1000 action block;
          # };

          ipv6 {   
              import filter {
                if is_valid_network_v6() && !is_self_net_v6() then {
                  if (roa_check(dn42_roa_v6, net, bgp_path.last) != ROA_VALID) then {
                    print "[dn42] ROA check failed for ", net, " ASN ", bgp_path.last;
                    reject;
                  } else accept;
                } else reject;
              };
              export filter { if is_valid_network_v6() && source ~ [RTS_STATIC, RTS_BGP] then accept; else reject; };
              import limit 1000 action block; 
          };
      }
      ${lib.concatStringsSep "\n" (lib.mapAttrsToList (name: conf: ''
        protocol bgp ${name}_v6 from dnpeers {
            neighbor ${conf.peer.wireguard.linkLocalAddress}%${conf.self.wireguard.interface} as ${toString conf.peer.asn};
        }
      '') config.dn42.peers)}
    '';
  };

  systemd = {
    timers.dn42-roa = {
      description = "Trigger a ROA table update";
      timerConfig = {
        OnBootSec = "5m";
        OnUnitInactiveSec = "1h";
        Unit = "dn42-roa.service";
      };
      wantedBy = [ "timers.target" ];
      before = [ "bird.service" ];
    };
    services.dn42-roa = {
      after = [ "network.target" ];
      description = "DN42 ROA Update";
      script = ''
        curl -sfSLR {-o,-z}/etc/bird/roa_dn42_v6.conf https://dn42.burble.com/roa/dn42_roa_bird2_6.conf
        # curl -sfSLR {-o,-z}/etc/bird/roa_dn42.conf https://dn42.burble.com/roa/dn42_roa_bird2_4.conf
        birdc c
        birdc reload in all
      '';
      path = with pkgs; [ curl bird ];
      serviceConfig = {
        User = "bird2";
        Group = "bird2";
      };
    };
  };
  systemd.tmpfiles.settings."10-bird"."/etc/bird".d = {
    group = "bird2";
    mode = "0755";
    user = "bird2";
  };

  security.pki.certificateFiles = [ ./dn42-ca.pem ];
}
