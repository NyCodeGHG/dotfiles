{ ... }:
{
  imports = [
    ./authentik
    ./coredns.nix
    ./forgejo
    ./miniflux.nix
    ./matrix
    ./ip-playground.nix
    ./nginx-meta.nix
    ./renovate.nix
    ./syncthing.nix
    ./iperf3.nix
    ./atuin.nix
    ./attic.nix
    ./kanidm.nix
    ./anubis.nix
    ./iplookupd.nix
    # ./hydra.nix
    ./garage.nix
    ./thelounge.nix
    ./proxyt.nix
  ];
}
