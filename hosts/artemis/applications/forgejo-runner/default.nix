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
      ];
      enable = true;
      tokenFile = config.age.secrets.forgejo-runner-token.path;
      name = "artemis";
    };
  };
  age.secrets.forgejo-runner-token.file = "${self}/secrets/forgejo-runner-token.age";
}