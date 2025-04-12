{ inputs, ... }:
{
  disabledModules = [ "services/misc/jellyseerr.nix" ];
  # TODO: remove when upgrading to 25.05
  imports = [
    "${inputs.nixpkgs-unstable}/nixos/modules/services/misc/jellyseerr.nix"
  ];
  services.jellyseerr = {
    enable = true;
  };
  services.nginx.virtualHosts."jellyseerr.marie.cologne".locations."/" = {
    proxyPass = "http://127.0.0.1:5055";
    proxyWebsockets = true;
  };
}
