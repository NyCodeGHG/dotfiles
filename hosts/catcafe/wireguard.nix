{ pkgs, config, lib, ... }:
{
  networking.wg-quick.interfaces = {
    wg0 = {
      address = [ "10.69.0.2/24" ];
      privateKeyFile = "/home/marie/wireguard-keys/private";

      peers = [
        {
          publicKey = "cIsemKHaYdTw/ki2RP3AfmYSx3f1G0ejent4N0yFDlg=";
          allowedIPs = [ "10.69.0.2/24" ];
          endpoint = "89.58.10.36:51820";
          persistentKeepalive = 25;
        }
      ];
    };
  };
}
