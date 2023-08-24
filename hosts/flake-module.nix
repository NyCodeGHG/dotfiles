{ lib, self, ... }:
let
  entries = builtins.attrNames (builtins.readDir ./.);
  configs = builtins.filter (dir: builtins.pathExists (./. + "/${dir}/configuration.nix")) entries;
in
{
  flake.nixosConfigurations = lib.listToAttrs
    (builtins.map
      (name:
        lib.nameValuePair
          (builtins.replaceStrings [ "." ] [ "-" ] name)
          (self.inputs.nixpkgs.lib.nixosSystem {
            system = "x86_64-linux";
            specialArgs = {
              inherit self;
            };

            modules = [
              (./. + "/${name}/configuration.nix")
              (./common.nix)
            ];
          }))
      configs);
}