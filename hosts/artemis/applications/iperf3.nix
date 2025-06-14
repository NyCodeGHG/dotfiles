{ lib, ... }:
{
  services.iperf3 = {
    enable = true;
    openFirewall = true;
  };

  systemd.services.iperf3.wantedBy = lib.mkForce [ ];
}
