{ config, lib, pkgs, graphical, ... }:
let
  filterNixFiles = k: v: v == "regular" && k != "default.nix" && lib.hasSuffix ".nix" k;
  importNixFiles = path: filter:
    with lib;
    (lists.forEach (mapAttrsToList (name: _: path + ("/" + name))
      (filterAttrs filter (builtins.readDir path))))
      import;
in
{
  imports = (importNixFiles ./headless filterNixFiles) ++ lib.flatten (lib.optional graphical (importNixFiles ./graphical filterNixFiles));

  options.uwumarie = {
    sshKey = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = ''
        Name of the ssh key file in ~/.ssh/.
      '';
    };
  };

  config = {
    home = {
      stateVersion = "22.11";
      username = "marie";
      homeDirectory = "/home/marie";
    };
  };
}
