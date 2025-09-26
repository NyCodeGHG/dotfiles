{ ... }:
{
  imports = [
    ./authentik.nix
    ./coredns.nix
    ./forgejo
    ./miniflux.nix
    ./matrix
    ./ip-playground.nix
    ./nginx-meta.nix
    ./renovate.nix
    ./syncthing.nix
    ./paperless.nix
    ./iperf3.nix
    ./atuin.nix
    ./attic.nix
    ./changedetection.nix
    ./soju.nix
    ./kanidm.nix
    ./anubis.nix
    ./iplookupd.nix
  ];
}
