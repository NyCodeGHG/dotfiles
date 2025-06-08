{ pkgs, lib, config, ... }:
{
  systemd.user.services = {
    peacock = {
      after = [ "network.target" ];
      wants = [ "network.target" ];
      description = "HITMAN™ World of Assassination trilogy server replacement";
      documentation = [ "https://thepeacockproject.org/wiki/" ];

      serviceConfig = {
        ExecStart = lib.getExe pkgs.peacock;
        WorkingDirectory = "%S/peacock";
        StateDirectory = "peacock";
      };

      environment = {
        PORT = "8790";
        LOG_LEVEL_CONSOLE = "info";
      };
    };
  };
}
