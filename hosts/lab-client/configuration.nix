{ modulesPath, ... }:
{
  imports = [
    "${modulesPath}/virtualisation/incus-virtual-machine.nix"
    ./networking.nix
  ];

  system.stateVersion = "26.05";

  security.sudo-rs.wheelNeedsPassword = false;
}
