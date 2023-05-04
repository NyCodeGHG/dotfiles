{
  description = "System configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    hyprland.url = "github:hyprwm/Hyprland/2df0d034bc4a18fafb3524401eeeceaa6b23e753";
  };

  outputs =
    { nixpkgs
    , home-manager
    , hyprland
    , ...
    } @ inputs:
    let
      lib = nixpkgs.lib;
      createSystem = { name, modules ? [ ], useHomeManager ? false, host }: lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./hosts/${name}
        ] ++ (lib.optionals useHomeManager [
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
          }
        ]) ++ modules;
        specialArgs = { inherit inputs host; };
      };
    in
    {
      nixosConfigurations = {
        catcafe = createSystem {
          name = "catcafe";
          modules = [
            hyprland.nixosModules.default
            { programs.hyprland.enable = true; }
            ./marie.nix
          ];
          useHomeManager = true;
          host = {
            sshKey = "github_laptop.ed25519";
          };
        };
        moonshine = createSystem {
          name = "moonshine";
          useHomeManager = true;
          modules = [
            ./marie.nix
          ];
          host = {
            sshKey = "github.ed25519";
          };
        };
      };
      formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.nixpkgs-fmt;
    };
}
