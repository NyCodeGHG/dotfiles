{ config, self, pkgs, ... }:
let
  renovateConfig = pkgs.writeText "renovate.json" (builtins.toJSON (import ./config.nix));
in
{
  age.secrets.renovate-env.file = "${self}/secrets/renovate-env.age";
  systemd.services.renovate = {
    environment = {
      RENOVATE_CONFIG_FILE = renovateConfig;
      LOG_LEVEL = "debug";
    };
    startAt = "hourly";
    path = [
      pkgs.git
      pkgs.openssh
      config.nix.package
      pkgs.rustc
      pkgs.cargo
    ];
    serviceConfig = {
      EnvironmentFile = config.age.secrets.renovate-env.path;
      Type = "oneshot";
      RemainAfterExit = true;
      Restart = "on-failure";
      StartLimitBurst = 3;
      RuntimeDirectory = "renovate";
      StateDirectory = "renovate";
      User = "renovate";
      Group = "renovate";
      ExecStart = "${self.packages.${pkgs.system}.renovate}/bin/renovate";
    };
  };
  users.users.renovate = {
    isSystemUser = true;
    createHome = false;
    home = "/var/lib/renovate";
    group = "renovate";
  };
  users.groups.renovate = { };
}
