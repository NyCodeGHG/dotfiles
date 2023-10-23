{
  perSystem = { pkgs, config, inputs', self', ... }: {
    packages = {
      node-mixin = pkgs.callPackage ./node-mixin { };
      inherit (pkgs.callPackage ./renovate { }) renovate;
      tf2-server = pkgs.callPackage ./tf2-server { };
      tf2-server-wrapped = pkgs.callPackage ./tf2-server/fhsenv.nix {
        tf2-server-unwrapped = self'.packages.tf2-server;
      };
      # preview-colors = pkgs.callPackage ./preview-colors { };
    };
  };
}
