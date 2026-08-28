{
  pkgs,
  lib,
  ...
}:
{
  systemd = {
    services.peacock = {
      description = "HITMAN™ World of Assassination trilogy server replacement";
      documentation = [ "https://thepeacockproject.org/wiki/" ];
      after = [ "peacock.socket" ];
      requires = [ "peacock.socket" ];
      serviceConfig = {
        ExecStart = lib.getExe pkgs.peacock;
        DynamicUser = true;
        StateDirectory = "peacock";
        WorkingDirectory = "%S/peacock";
        PrivateTmp = true;
      };
      environment = {
        LOG_LEVEL_CONSOLE = "info";
      };
    };
    sockets.peacock = {
      listenStreams = [
        "127.0.0.1:8790"
      ];
      wantedBy = [ "sockets.target" ];
    };
  };
}
