{ self, ... }:
let
  inherit (self) inputs;
in
{
  imports = [
    ../../profiles/nix-config.nix
    ../../profiles/nginx.nix
    ../../profiles/acme.nix
    ../../profiles/openssh.nix
    ../../profiles/locale.nix
    ../../profiles/fail2ban.nix
    ./monitoring
    ./applications
    ./hardware.nix
    ./postgres.nix
    ./wireguard.nix
    ./restic.nix
    ./networking.nix
  ] ++ (with inputs; [
    agenix.nixosModules.default
    vscode-server.nixosModules.default
    home-manager.nixosModules.home-manager
  ]);

  services.vscode-server.enable = true;
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.marie = import "${self}/home";
    extraSpecialArgs = { inherit inputs; graphical = false; };
  };

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";

  security.sudo.wheelNeedsPassword = false;

  console.keyMap = "de";
  nixpkgs.config.allowUnfree = true;

  system.stateVersion = "22.11";
}
