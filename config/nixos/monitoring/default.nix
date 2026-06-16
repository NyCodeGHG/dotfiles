{
  services.alloy.enable = true;

  systemd.services.alloy = {
    after = [
      "tailscaled.service"
      "network-online.target"
    ];
    wants = [ "network-online.target" ];
  };

  environment.etc."alloy/config.alloy".source = ./common.alloy;
}
