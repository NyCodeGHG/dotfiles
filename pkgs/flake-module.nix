{
  perSystem = { pkgs, config, inputs', self', ... }: {
    packages = {
      sandwine = pkgs.callPackage ./sandwine { };
      qpm-cli = pkgs.callPackage ./qpm-cli { };
      wgsl-analyzer = pkgs.callPackage ./wgsl-analyzer/package.nix { };
    };
  };
}
