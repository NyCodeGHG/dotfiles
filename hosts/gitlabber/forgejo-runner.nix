{ config, pkgs, ... }:
{
  services.gitea-actions-runner = {
    package = pkgs.forgejo-runner;
    instances = {
      "gitlabber-01" = {
        enable = true;
        name = "gitlabber-01";
        labels = [
          "ubuntu-22.04:docker://ghcr.io/catthehacker/ubuntu:runner-22.04"
        ];
        tokenFile = config.age.secrets.forgejo-runner.path;
        url = "https://git.marie.cologne";
      };
    };
  };
  virtualisation.podman = {
    enable = true;
    dockerSocket.enable = true;
    defaultNetwork.settings = {
      dns_enabled = true;
    };
  };
  networking.firewall.interfaces."podman+" = {
    allowedUDPPorts = [ 53 ];
    allowedTCPPorts = [ 53 ];
  };
  age.secrets.forgejo-runner.file = ./forgejo-runner.age;
}
