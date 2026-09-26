{ pkgs, ... }:
{
  specialisation.enocean-forwarder.configuration = {
    systemd.services.enocean-forwarder = {
      requires = [ "dev-ttyAMA0.device" ];
      after = [ "dev-ttyAMA0.device" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        DynamicUser = true;
        PrivateNetwork = true;
        ExecStart = "${pkgs.socat}/bin/socat UNIX-LISTEN:%t/enocean/enocean.sock,fork,mode=660,group=enocean /dev/ttyAMA0,ispeed=57600,ospeed=57600,cfmakeraw,cs8,parenb=0,cstopb=0,crtscts=0,clocal=1";
        DeviceAllow = "/dev/ttyAMA0 rw";
        SupplementaryGroups = [
          "dialout"
          "enocean"
        ];
        RuntimeDirectory = "enocean";
      };
    };

    systemd.services.enocean2mqtt.enable = false;
  };
  users = {
    groups.enocean = { };
    users.marie.extraGroups = [ "enocean" ];
  };
}
