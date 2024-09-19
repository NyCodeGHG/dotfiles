{
  perSystem = { pkgs, config, inputs', self', ... }: {
    packages = {
      # preview-colors = pkgs.callPackage ./preview-colors { };
      sandwine = pkgs.callPackage ./sandwine { };
    };
  };
}
