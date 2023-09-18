{ self, ... }:
{
  imports = [
    ./paperless.nix
    # ./traewelling.nix
    ./minio.nix
  ];
}
