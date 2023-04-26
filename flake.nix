{
  description = "System configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    hyprland.url = "github:hyprwm/Hyprland/2df0d034bc4a18fafb3524401eeeceaa6b23e753";
  };

  outputs = {
    nixpkgs,
    home-manager,
    hyprland,
    ...
  } @ inputs: {
    nixosConfigurations.catcafe = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./catcafe.nix
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
        }
        hyprland.nixosModules.default
        {programs.hyprland.enable = true;}
      ];
      specialArgs = {inherit inputs;};
    };
    formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.alejandra;
  };
}
