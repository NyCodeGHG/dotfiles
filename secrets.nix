let
  pkgs = import <nixpkgs> { };
  inherit (pkgs) lib;
  keys = import ./keys { inherit lib; };
  hosts = [ "marie-nas" ];

  flattenAttrs = lib.foldr lib.recursiveUpdate { };
  makeRelative = lib.removePrefix "${(toString ./.)}/";

  findHostSecrets =
    host:
    lib.pipe host [
      (host: lib.filesystem.listFilesRecursive ./hosts/${host})
      (lib.filter (lib.hasSuffix ".age"))
      (map toString)
      (map makeRelative)
      (map (f: {
        "${f}" = {
          publicKeys = [
            keys.marie
            keys.${host}
          ];
          armor = true;
        };
      }))
      flattenAttrs
    ];

in
lib.pipe hosts [
  (map findHostSecrets)
  flattenAttrs
]
