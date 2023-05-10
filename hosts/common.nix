{ pkgs, config, lib, agenix, ... }:
{
  services.mullvad-vpn.enable = true;
  environment.systemPackages = [ agenix ];
}
