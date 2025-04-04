{ pkgs, inputs, ... }:
{
  users.groups.corsair = { };
  users.users.marie.extraGroups = [ "corsair" ];

  # corsair headset userspace access
  services.udev.extraRules = ''
    SUBSYSTEM=="hidraw", ATTRS{idVendor}=="1b1c", ATTRS{idProduct}=="0a6b", GROUP="corsair"
  '';

  systemd.user.services.corsair-hs80-pipewire-thing = {
    serviceConfig = {
      ExecStart = "${inputs.corsair-hs80-pipewire-thing.packages.${pkgs.stdenv.hostPlatform.system}.default}/bin/corsair-hs80-pipewire-thing";
    };
    wantedBy = [ "graphical-session.target" ];
  };
}
