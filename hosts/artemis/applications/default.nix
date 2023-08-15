{ ... }:
{
  imports = [
    ./authentik.nix
    ./coder.nix
    ./gitlab
    ./forgejo
    ./jellyfin.nix
    ./miniflux.nix
    ./matrix
    ./ip-playground.nix
    ./pgrok.nix
    ./tika.nix
    ./nginx-meta.nix
  ];
}
