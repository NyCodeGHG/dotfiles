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
}