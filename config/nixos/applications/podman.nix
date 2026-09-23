{ config, lib, ... }:
lib.mkIf config.virtualisation.podman.enable {
  networking.firewall.extraForwardRules = ''
    iifname "podman*" accept;
  '';
  virtualisation.podman.defaultNetwork.settings = {
    dns_enabled = true;
  };
}
