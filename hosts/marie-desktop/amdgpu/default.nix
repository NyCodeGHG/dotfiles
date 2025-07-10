{ pkgs, config, ... }:
{
  boot.extraModulePackages = [
    (pkgs.callPackage ./package.nix {
      inherit (config.boot.kernelPackages) kernel;
    })
  ];
}
