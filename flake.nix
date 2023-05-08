{
  description = "System configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-22.11";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    hyprland.url = "github:hyprwm/Hyprland/2df0d034bc4a18fafb3524401eeeceaa6b23e753";
  };

  outputs =
    { self
    , nixpkgs
    , nixpkgs-stable
    , home-manager
    , hyprland
    , ...
    } @ inputs:
    let
      createSystem = { name, modules ? [ ], useHomeManager ? false, host ? { }, pkgs ? nixpkgs }: pkgs.lib.nixosSystem {
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
        specialArgs = {
          inherit inputs host;
          jellyfin = self.packages.x86_64-linux.jellyfin;
          jellyfin-intro-skipper = self.packages.x86_64-linux.jellyfin-intro-skipper;
        };
      };
      pkgs = import nixpkgs { system = "x86_64-linux"; };
    in
    {
      nixosConfigurations = {
        catcafe = createSystem {
          name = "catcafe";
          modules = [
            hyprland.nixosModules.default
            { programs.hyprland.enable = true; }
            ./marie.nix
            ./hosts/common.nix
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
            ./hosts/common.nix
          ];
          host = {
            sshKey = "github.ed25519";
          };
        };
        artemis = createSystem {
          name = "artemis";
          pkgs = nixpkgs-stable;
        };
      };
      formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.nixpkgs-fmt;
      packages.x86_64-linux = pkgs.callPackage ./jellyfin { };
    };
}
