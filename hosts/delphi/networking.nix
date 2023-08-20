{ ... }:
{
  networking = {
    hostName = "delphi";
    # Use OCI firewall
    firewall.enable = false;
    nameservers = [
      "1.1.1.1"
      "1.0.0.1"
    ];
  };
  networking.firewall.interfaces.wg0.allowedTCPPorts = [ 9100 3031 ];
}
