{ ... }:
{
  imports = [
    ./authentik.nix
    ./coredns.nix
    ./forgejo
    ./forgejo-runner
    ./miniflux.nix
    ./matrix
    ./ip-playground.nix
    ./pgrok.nix
    ./tika.nix
    ./nginx-meta.nix
    ./renovate
    ./syncthing.nix
  ];
}
