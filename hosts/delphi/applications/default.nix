{ self, ... }:
{
  imports = [
    ./paperless.nix
    # ./traewelling.nix
    ./minio.nix
    ./coturn.nix
    ./db-rest.nix
  ];
}
