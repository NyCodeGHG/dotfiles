{ ... }:
{
  services.openthread-border-router = {
    enable = true;
    backboneInterfaces = [ "br0" ];
    logLevel = "warning";
    radio = {
      device = "/dev/serial/by-id/usb-Nabu_Casa_ZBT-2_E072A1D7903C-if00";
      baudRate = 460800;
      flowControl = true;
    };
    rest.listenPort = 8081;
    web.enable = true;
  };

  # TODO: Remove after https://github.com/rust-netlink/netlink-packet-route/pull/338 shipped
  virtualisation.podman.defaultNetwork.settings.options.mtu = "1500";

  systemd.services.otbr-agent = {
    startLimitIntervalSec = 0;
    serviceConfig = {
      RestartSteps = 5;
      RestartMaxDelaySec = "5min";
    };
  };

  networking.firewall.extraForwardRules = ''
    iifname "wpan0" accept
    oifname "wpan0" accept
  '';
}
