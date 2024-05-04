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
    ./renovate
    ./syncthing.nix
    ./paperless.nix
  ];
}
