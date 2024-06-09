{ config, inputs, pkgs, ... }:
{
  imports = [
    inputs.self.nixosModules.renovate
  ];
  services.renovate = {
    enable = true;
    package = inputs.nixpkgs-unstable.legacyPackages.${pkgs.stdenv.hostPlatform.system}.callPackage ../../../pkgs/renovate {};
    schedule = "hourly";
    settings = {
      platform = "gitea";
      endpoint = "https://git.marie.cologne";
      gitAuthor = "Renovate <renovate@git.marie.cologne>";
      autodiscover = true;
      autodiscoverTopics = [ "managed-by-renovate" ];
      nix.enabled = true;
      lockFileMaintenance.enabled = true;
      # experimental
      osvVulnerabilityAlerts = true;
    };
    credentials = {
      RENOVATE_TOKEN = config.age.secrets.renovate-token.path;
      GITHUB_COM_TOKEN = config.age.secrets.renovate-github-token.path;
    };
    runtimePackages = with pkgs; [
      config.nix.package
      nodejs
      corepack
    ];
  };
  age.secrets.renovate-token.file = ../secrets/renovate-token.age;
  age.secrets.renovate-github-token.file = ../secrets/renovate-github-token.age;
}
