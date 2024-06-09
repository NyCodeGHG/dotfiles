{
  perSystem = { pkgs, config, inputs', self', ... }: {
    packages = {
      node-mixin = pkgs.callPackage ./node-mixin { };
      # preview-colors = pkgs.callPackage ./preview-colors { };
      guard-nvim = pkgs.callPackage ./guard-nvim { };
      deploy = pkgs.callPackage ../tools/deploy { };
    };
  };
}
