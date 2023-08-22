{ modulesPath, ... }:
{
  imports = [
    "${modulesPath}/profiles/qemu-guest.nix"
    "${modulesPath}/profiles/headless.nix"
    ../../profiles/locale.nix
    ../../profiles/openssh.nix
    ../../profiles/nix-config.nix
    ../../profiles/locale.nix
    ./networking.nix
  ];
}