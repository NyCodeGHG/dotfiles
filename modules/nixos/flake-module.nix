{
  flake.nixosModules = {
    authentik = import ./applications/authentik.nix;
    coder = import ./applications/coder.nix;
    pgrok = import ./applications/pgrok.nix;
    #scanservjs = import ./applications/scanservjs.nix;
  };
}
