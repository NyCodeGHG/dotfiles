{ lib, self, ... }:
let
  entries = builtins.attrNames (builtins.readDir ./.);
  configs = builtins.filter (dir: builtins.pathExists (./. + "/${dir}/configuration.nix")) entries;
  systemArch = {
    "artemis" = "x86_64-linux";
    "delphi" = "aarch64-linux";
    "insane" = "x86_64-linux";
  };
in
{
  flake.nixosConfigurations = lib.listToAttrs
    (builtins.map
      (name:
        lib.nameValuePair
          (builtins.replaceStrings [ "." ] [ "-" ] name)
          (self.inputs.nixpkgs.lib.nixosSystem {
            system = systemArch.${name};
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
