{ config, lib, pkgs, ... }:
let
  port = 51820;
in
{
  networking.wireguard = {
    enable = true;
    interfaces = {
      wg0 = {
        ips = [ "10.69.0.7/24" ];
        listenPort = port;
        privateKeyFile = config.age.secrets.delphi-wg-privatekey.path;
        peers = [
          {
            name = "artemis";
            publicKey = "cIsemKHaYdTw/ki2RP3AfmYSx3f1G0ejent4N0yFDlg=";
            allowedIPs = [ "10.69.0.0/24" ];
            endpoint = "89.58.10.36:${builtins.toString port}";
            # persistentKeepalive is not needed here, because we're not behind nat
          }
        ];
      };
    };
  };
  age.secrets.delphi-wg-privatekey.file = ../../secrets/delphi-wg-privatekey.age;
}
