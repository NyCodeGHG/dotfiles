{ ... }:
{
  imports = [
    ./authentik.nix
    ./coder.nix
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
