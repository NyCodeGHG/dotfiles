{ pkgs, config, self, ... }:
{
  services.gitea-actions-runner = {
    package = pkgs.forgejo-actions-runner;
    instances.default = {
      url = "https://git.marie.cologne";
      labels = [
        # provide a debian base with nodejs for actions
        "debian-latest:docker://node:18-bullseye"
        # fake the ubuntu name, because node provides no ubuntu builds
        "ubuntu-latest:docker://node:18-bullseye"
        # provide native execution on the host
        "native:host"
        "nix:docker://git.marie.cologne/marie/ci-images/base"
      ];
      enable = true;
      tokenFile = config.age.secrets.forgejo-runner-token.path;
      name = "artemis";
    };
  };
  age.secrets.forgejo-runner-token.file = "${self}/secrets/forgejo-runner-token.age";
  virtualisation.podman.defaultNetwork.settings.dns_enable = true;
  networking.firewall.interfaces."podman*" = {
    allowedUDPPorts = [ 53 ];
    allowedTCPPorts = [ 53 ];
  };
}