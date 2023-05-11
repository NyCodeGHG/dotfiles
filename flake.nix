{
  description = "System configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-22.11";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    agenix.inputs.nixpkgs.follows = "nixpkgs";
    agenix.url = "github:ryantm/agenix";
    flake-utils.url = "github:numtide/flake-utils";

    hyprland.url = "github:hyprwm/Hyprland/2df0d034bc4a18fafb3524401eeeceaa6b23e753";
  };

  outputs =
    { self
    , nixpkgs
    , nixpkgs-stable
    , home-manager
    , hyprland
    , agenix
    , flake-utils
    , ...
    } @ inputs:
    let
      pkgs = import nixpkgs { system = "x86_64-linux"; };
      createSystem = { name, modules ? [ ], useHomeManager ? false, host ? { }, }: nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./hosts/${name}
          agenix.nixosModules.default
        ] ++ (pkgs.lib.optionals useHomeManager [
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
          agenix = agenix.packages.x86_64-linux.default;
        };
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
        };
      };
      formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.nixpkgs-fmt;
    } // flake-utils.lib.eachDefaultSystem (system:
    let
      pkgs = import nixpkgs { inherit system; };
      jellyfinPkgs = pkgs.callPackage ./jellyfin { };
      vms = nixpkgs.lib.attrsets.mapAttrs'
        (name: value: (nixpkgs.lib.attrsets.nameValuePair ("${name}-vm") value.config.system.build.vm))
        self.nixosConfigurations;
    in
    {
      packages = vms // {
        figlet-preview = (pkgs.callPackage ./scripts/figlet-preview.nix { });
        jellyfin = jellyfinPkgs.jellyfin;
        jellyfin-web = jellyfinPkgs.jellyfin-web;
        jellyfin-intro-skipper = jellyfinPkgs.jellyfin-intro-skipper;
      };
    }
    );
}
