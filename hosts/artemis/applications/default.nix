{ ... }:
{
  imports = [
    ./authentik.nix
    ./coredns.nix
    ./forgejo
    ./miniflux.nix
    ./matrix
    ./ip-playground.nix
    ./pgrok.nix
    ./nginx-meta.nix
    ./renovate.nix
    ./syncthing.nix
    ./paperless.nix
    ./iperf3.nix
    ./hedgedoc
    ./jellyfin.nix
    ./netbox
  ];
}
