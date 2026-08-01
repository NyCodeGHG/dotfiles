{ config, pkgs, ... }:
{
  services.forgejo-runner.instances.gitlabber = {
    enable = true;
    settings = {
      runner.labels = [
        "ubuntu-22.04:docker://ghcr.io/catthehacker/ubuntu:runner-22.04"
        "nix-x86_64:host"
      ];
      server.connections.forgejo = {
        url = "https://git.marie.cologne";
        uuid = "f2489060-dc35-4ee0-ae1b-7cd870caa1d0";
      };
    };
    secrets.server.connections.forgejo.token_url = config.age.secrets.forgejo-runner-token.path;
  };
  age.secrets.forgejo-runner-token.file = ./forgejo-runner-token.age;

  virtualisation.podman = {
    enable = true;
    dockerSocket.enable = true;
    extraPackages = [ pkgs.nftables ];
    defaultNetwork.settings = {
      dns_enabled = true;
    };
  };
  networking.firewall.trustedInterfaces = [ "podman*" ];
}
