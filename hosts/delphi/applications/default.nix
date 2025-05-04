{ self, ... }:
{
  imports = [
    # ./traewelling.nix
    ./minio.nix
    ./syncthing.nix
  ];
}
