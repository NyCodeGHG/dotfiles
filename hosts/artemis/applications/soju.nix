{ 
  lib,
  pkgs,
  ...
}:

let
  configFile = pkgs.writeText "soju.conf" ''
    listen irc+insecure://[::]:6667 
    listen unix+admin:///run/soju/admin
    hostname artemis.marie.cologne
    db postgres "host=/run/postgresql dbname=soju"
    message-store db
  '';
  sojuctl = pkgs.writeShellScriptBin "sojuctl" ''
    exec ${lib.getExe' pkgs.soju "sojuctl"} --config ${configFile} "$@"
  '';
in
{
  services.postgresql = {
    enable = true;
    ensureDatabases = [ "soju" ];
    ensureUsers = [{
      name = "soju";
      ensureDBOwnership = true;
    }];
  };

  environment.systemPackages = [ sojuctl ];

  systemd.services.soju = {
    description = "soju IRC bouncer";
    wantedBy = [ "multi-user.target" ];
    wants = [ "network-online.target" ];
    after = [ "network-online.target" ];
    serviceConfig = {
      DynamicUser = true;
      Restart = "always";
      ExecStart = "${lib.getExe' pkgs.soju "soju"} -config ${configFile}";
      StateDirectory = "soju";
      RuntimeDirectory = "soju";
    };
  };
}
