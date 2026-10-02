{ pkgs, config, ... }:
{
  imports = [
    ../../config/nixos/applications/tailscale.nix
  ];

  services.resolved.enable = true;
  networking.nftables.enable = true;
  time.timeZone = "UTC";
  i18n.defaultLocale = "en_US.UTF-8";

  networking.useDHCP = false;
  networking.hostName = "iot-interceptor";

  systemd.network = {
    enable = true;
    config.networkConfig = {
      IPv6Forwarding = true;
      IPv6PrivacyExtensions = false;
    };
    networks = {
      "10-wan" = {
        matchConfig = {
          Kind = "!*";
          Type = "ether";
        };
        networkConfig = {
          DHCP = true;
          IPv6AcceptRA = true;
          IPv6Forwarding = true;
          IPv4Forwarding = true;
        };
        dhcpV6Config = {
          PrefixDelegationHint = "::/60";
          WithoutRA = "solicit";
          UseAddress = false;
        };
      };
      "20-wifi" = {
        matchConfig = {
          Name = "wlan0";
          Type = "wlan";
        };
        networkConfig = {
          DHCPPrefixDelegation = true;
          IPv6Forwarding = true;
          IPv6SendRA = true;
          IPv6AcceptRA = false;

          DHCPServer = true;
          IPv4Forwarding = true;
          IPMasquerade = "ipv4";
          Address = [ "192.168.2.1/24" ];
        };
        linkConfig = {
          RequiredForOnline = false;
        };
        dhcpPrefixDelegationConfig = {
          Token = "::1";
        };
      };
    };
  };

  networking.firewall = {
    interfaces.wlan0.allowedUDPPorts = [ 67 ];
    extraForwardRules = ''
      iifname "wlan0" oifname "enu1u1u1" accept
    '';
  };

  services.hostapd = {
    enable = true;
    radios.wlan0 = {
      countryCode = "DE";
      band = "2g";
      channel = 1;
      wifi4 = {
        enable = true;
        capabilities = [ "SHORT-GI-20" ];
      };
      wifi5.enable = false;
      wifi6.enable = false;
      wifi7.enable = false;
      networks = {
        wlan0 = {
          ssid = "IoT";
          authentication = {
            enableRecommendedPairwiseCiphers = false;
            mode = "wpa2-sha1";
            wpaPasswordFile = config.age.secrets.wifi-password.path;
          };
        };
      };
    };
  };

  age.secrets = {
    wifi-password.file = ./secrets/wifi-password.age;
  };

  environment.systemPackages = [ pkgs.iw ];
}
