{ pkgs, config, lib, agenix, ... }:
{
  services.mullvad-vpn.enable = true;
  environment.systemPackages = [ agenix pkgs.lshw pkgs.pciutils pkgs.speedtest-cli pkgs.iw ];
}
