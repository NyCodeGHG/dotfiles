{ pkgs, inputs, ... }:
{
  users.groups.corsair = { };
  users.users.marie.extraGroups = [ "corsair" ];

  # corsair headset userspace access
  services.udev.extraRules = ''
    SUBSYSTEM=="hidraw", ATTRS{idVendor}=="1b1c", ATTRS{idProduct}=="0a6b", GROUP="corsair", TAG+="systemd", ENV{SYSTEMD_WANTS}="corsair-hs80-pipewire-thing.service"
  '';

  systemd.services.corsair-hs80-pipewire-thing = {
    serviceConfig = {
      ExecStart = "${inputs.corsair-hs80-pipewire-thing.packages.${pkgs.stdenv.hostPlatform.system}.default}/bin/corsair-hs80-pipewire-thing";
      User = "marie";
      Group = "corsair";
    };
    unitConfig = {
      StopWhenUnneeded = true;
    };
  };
}
