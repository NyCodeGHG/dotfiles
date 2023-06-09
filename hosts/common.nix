{ pkgs, config, lib, agenix, ... }:
{
  imports = [
    ../users/marie
  ];
  environment.systemPackages = [ agenix pkgs.lshw pkgs.pciutils pkgs.speedtest-cli pkgs.iw ];
}
