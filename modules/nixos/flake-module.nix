{
  flake.nixosModules = {
    authentik = import ./applications/authentik.nix;
    coder = import ./applications/coder.nix;
    pgrok = import ./applications/pgrok.nix;
    nspawnTarball = import ./nspawn-tarball.nix;
    #scanservjs = import ./applications/scanservjs.nix;
  };
}
