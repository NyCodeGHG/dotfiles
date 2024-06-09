{
  flake.nixosModules = {
    authentik = ./applications/authentik.nix;
    coder = ./applications/coder.nix;
    pgrok = ./applications/pgrok.nix;
    nspawnTarball = ./nspawn-tarball.nix;
    cachixUpload = ./cachix-upload.nix;
    renovate = ./applications/renovate.nix;
    #scanservjs = import ./applications/scanservjs.nix;
  };
}
