{ config, ... }:
{
  services.syncthing = {
    enable = true;
    settings = {
      devices = {
        "marie-desktop".id = "U3EOIRR-FLOIAZH-53X32J7-YRMDHK6-V3DRAIZ-EAZIZR6-DHZMCF3-THYCQQF";
        "artemis".id = "A7DXG37-5LFGSFT-A23TL6T-6FPR7WI-T2R626H-NCN4ISY-N6BY4W6-ETRJCQC";
      };
      gui.insecureSkipHostcheck = true;
      folders = {
        "cabin-modpack" = {
          path = "/var/lib/minecraft/cabin/backups";
          devices = [ "marie-desktop" ];
        };
      };
    };
  };
  security.acme.certs."marie.cologne".extraDomainNames = [ "*.delphi.marie.cologne" ];
  services.nginx.virtualHosts."syncthing.delphi.marie.cologne" = {
    locations."/" = {
      proxyPass = "http://${config.services.syncthing.guiAddress}";
      proxyWebsockets = true;
      extraConfig = ''
        allow 127.0.0.0/24;
        allow 10.69.0.5/32;
        deny all;
      '';
    };
  };
  # syncthing data + discovery ports
  networking.firewall.interfaces.wg0 = {
    allowedTCPPorts = [ 22000 ];
    allowedUDPPorts = [
      21027
      22000
    ];
  };
  users.users.syncthing.extraGroups = [ "minecraft" ];
}
