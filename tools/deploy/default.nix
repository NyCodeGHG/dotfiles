{ lib, rustPlatform }:
let
  fs = lib.fileset;
in
rustPlatform.buildRustPackage rec {
  pname = "deploy";
  inherit ((lib.importTOML ./Cargo.toml).package) version;

  src = fs.toSource {
    root = ./.;
    fileset = fs.unions [
      ./Cargo.toml
      ./Cargo.lock
      ./src
    ];
  };
  cargoLock.lockFile = ./Cargo.lock;
}
