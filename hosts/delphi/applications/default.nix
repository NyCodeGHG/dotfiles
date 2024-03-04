{ self, ... }:
{
  imports = [
    # ./traewelling.nix
    ./minio.nix
    ./coturn.nix
    ./syncthing.nix
  ];
}
