{
  perSystem = { pkgs, config, inputs', self', ... }: {
    packages = {
      # preview-colors = pkgs.callPackage ./preview-colors { };
      guard-nvim = pkgs.callPackage ./guard-nvim { };
      sandwine = pkgs.callPackage ./sandwine { };
    };
  };
}
