{ lib }:

let
  readKey =
    file:
    let
      name = lib.removeSuffix ".txt" file;
      content = lib.trim (lib.readFile ./${file});
    in
    lib.nameValuePair name content;
in

lib.pipe (lib.readDir ./.) [
  (lib.filterAttrs (n: v: v != "directory" && (lib.hasSuffix ".txt" n)))
  (lib.mapAttrs' (n: v: readKey n))
]
