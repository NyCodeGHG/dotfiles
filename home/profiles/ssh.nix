{ pkgs, ... }:
{
  programs.ssh = {
    enable = true;
    package = pkgs.openssh;
    matchBlocks = {
      "github.com" = {
        user = "git";
        identitiesOnly = true;
        identityFile = "~/.ssh/github.ed25519";
      };
      catcafe = {
        hostname = "192.168.1.35";
        identityFile = "~/.ssh/github.ed25519";
      };
      artemis = {
        hostname = "nue01.marie.cologne";
        identitiesOnly = true;
        identityFile = "~/.ssh/default.ed25519";
      };
      delphi = {
        hostname = "oci-fra01.marie.cologne";
        identitiesOnly = true;
        identityFile = "~/.ssh/default.ed25519";
      };
      raspberrypi = {
        user = "pi";
        identityFile = "~/.ssh/default.ed25519";
        identitiesOnly = true;
      };
      nas = {
        hostname = "10.69.0.8";
        identityFile = "~/.ssh/default.ed25519";
        identitiesOnly = true;
      };
      "*" ={
        extraOptions = {
          AddKeysToAgent = "yes";
        };
      };
    };
  };
  services.ssh-agent.enable = true;
}