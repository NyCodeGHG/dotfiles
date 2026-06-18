{ ... }:
{
  services.openthread-border-router = {
    enable = true;
    backboneInterfaces = [ "br0" ];
    logLevel = "warning";
    radio = {
      device = "/dev/serial/by-id/usb-Itead_Sonoff_Zigbee_3.0_USB_Dongle_Plus_V2_b2755e278739ef11a42a53f454516304-if00-port0";
      baudRate = 460800;
      flowControl = false;
    };
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
