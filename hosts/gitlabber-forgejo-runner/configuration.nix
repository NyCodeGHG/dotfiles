{ pkgs, modulesPath, config, ... }:

let
  hostPackages = with pkgs; [
    bash
    coreutils
    curl
    gawk
    gitMinimal
    gnused
    nodejs
    wget
    podman
    skopeo
  ];
in
  
{
  imports = [
    (modulesPath + "/profiles/minimal.nix")
  ];
  networking.hostName = "gitlabber-forgejo-runner";
  uwumarie.profiles = {
    nspawn = true;
  };

  users.users.marie.initialHashedPassword = "$y$j9T$QuvIaMM4RuzxPVXeK4lay.$yui1R8EHsBwdYNw48lML3iEkJMGNkMRAVgeVFDq6hD2";

  virtualisation.podman.enable = true;

  age.secrets.forgejo-runner-1.file = ./secrets/forgejo-runner-1.age;
  services.gitea-actions-runner = {
    package = pkgs.forgejo-actions-runner;
    instances = {
      "gitlabber-1" = {
        enable = true;
        name = "gitlabber-1";
        url = "https://git.marie.cologne";
        labels = [ "native:host" ];
        inherit hostPackages;
        tokenFile = config.age.secrets.forgejo-runner-1.path;
      };
    };
  };

  system.stateVersion = "23.11";
  nixpkgs.hostPlatform = "x86_64-linux";
}
