{ pkgs, ... }:
{
  systemd.sockets.enocean-forwarder = {
    requires = [ "dev-ttyAMA0.device" ];
    after = [ "dev-ttyAMA0.device" ];
    wantedBy = [ "sockets.target" ];
    socketConfig = {
      ListenStream = "/run/enocean.sock";
      Accept = true;
      MaxConnections = 1;
      SocketGroup = "enocean";
      SocketMode = "0660";
    };
  };

  systemd.services."enocean-forwarder@" = {
    serviceConfig = {
      DynamicUser = true;
      PrivateNetwork = true;
      ExecStartPre = "${pkgs.coreutils}/bin/stty -F /dev/ttyAMA0 57600 cs8 -cstopb -parenb -crtscts clocal raw -echo";
      ExecStart = "${pkgs.socat}/bin/socat - /dev/ttyAMA0";
      StandardInput = "socket";
      StandardError = "journal";
      DeviceAllow = "/dev/ttyAMA0";
    };
  };

  users = {
    groups.enocean = { };
    users.marie.extraGroups = [ "enocean" ];
  };
}
