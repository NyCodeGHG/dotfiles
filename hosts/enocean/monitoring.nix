{
  imports = [
    ../../config/nixos/monitoring
  ];

  services.alloy = {
    enable = true;
    extraFlags = [
      "--storage.path=/tmp/alloy"
      "--disable-reporting"
    ];
  };
  systemd.services.alloy.serviceConfig = {
    PrivateTmp = true;
  };
}
