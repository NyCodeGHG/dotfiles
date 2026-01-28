{
  pkgs,
  lib,
  config,
  ...
}:
let
  package = pkgs.corsair-hs80-pipewire-thing;
in
{
  options.uwumarie.profiles.corsair = lib.mkEnableOption "Corsair HS80 tool";
  config = lib.mkIf config.uwumarie.profiles.corsair {
    users.groups.corsair = { };
    users.users.marie.extraGroups = [ "corsair" ];

    # corsair headset userspace access
    services.udev.extraRules = ''
      SUBSYSTEM=="hidraw", ATTRS{idVendor}=="1b1c", ATTRS{idProduct}=="0a6b", GROUP="corsair"
    '';

    systemd.user.services.corsair-hs80-pipewire-thing = {
      serviceConfig = {
        ExecStart = lib.getExe package;
      };
      unitConfig = {
        ConditionUser = "marie";
      };
      wantedBy = [ "graphical-session.target" ];
    };

    environment.systemPackages = [ package ];
  };
}
