{
  services.alloy.enable = true;

  systemd.services.alloy = {
    after = [
      "tailscaled.service"
      "tailscale-online.target"
      "network-online.target"
    ];
    wants = [
      "network-online.target"
      "tailscale-online.target"
    ];
  };

  environment.etc."alloy/config.alloy".source = ./common.alloy;
}
