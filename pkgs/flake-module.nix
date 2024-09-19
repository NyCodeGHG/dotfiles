{
  perSystem = { pkgs, config, inputs', self', ... }: {
    packages = {
      sandwine = pkgs.callPackage ./sandwine { };
    };
  };
}
