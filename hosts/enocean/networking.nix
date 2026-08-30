{
  imports = [
    ../../config/nixos/applications/tailscale.nix
  ];

  services.resolved.enable = true;
  networking.nftables.enable = true;
  time.timeZone = "UTC";
  i18n.defaultLocale = "en_US.UTF-8";

  networking.useDHCP = false;
  networking.hostName = "enocean";
  systemd.network = {
    enable = true;
    networks.ethernet = {
      matchConfig = {
        Kind = "!*";
        Type = "ether";
      };
      networkConfig = {
        DHCP = true;
      };
    };
  };
}
