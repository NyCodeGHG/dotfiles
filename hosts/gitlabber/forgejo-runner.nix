{ config, pkgs, ... }:
{
  services.forgejo-runner.instances.gitlabber = {
    enable = true;
    hostPackages = with pkgs; [
      bash
      coreutils
      curl
      gawk
      gnused
      nodejs
      wget
      config.nix.package
      jq
      openssh
    ];
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

  programs.ssh.knownHosts = {
    "git.marie.cologne".publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAFQjqgMtqrMy7AKCQN4aMZitASg9MWEP1u6lfVdA0v8 root@artemis";
  };
}
