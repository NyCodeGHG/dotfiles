{ withSystem, ... }:
{
  flake.nixosModules = {
    traewelling = { pkgs, ... }: {
      imports = [ ./traewelling.nix ];
      services.traewelling.package = withSystem pkgs.stdenv.hostPlatform.system ({ config, ... }: 
        config.packages.traewelling
      );
    };
  };
}