{ pkgs, ... }:
{
  programs.ssh = {
    enable = true;
    package = pkgs.openssh;
    matchBlocks = {
      "github.com" = {
        user = "git";
      };
      artemis = {
        hostname = "nue01.marie.cologne";
      };
      delphi = {
        hostname = "oci-fra01.marie.cologne";
      };
      raspberrypi = {
        user = "pi";
      };
    };
  };
  services.ssh-agent.enable = true;
}