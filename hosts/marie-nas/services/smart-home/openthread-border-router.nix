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
    rest.listenPort = 8083;
    web.enable = true;
  };

  systemd.services.otbr-agent = {
    startLimitIntervalSec = 0;
    serviceConfig = {
      RestartSteps = 5;
      RestartMaxDelaySec = "5min";
    };
  };
}
