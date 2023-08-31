{ ... }:
let
  tikaPort = 33001;
in
{
  virtualisation.oci-containers.containers.tika = {
    image = "docker.io/apache/tika:2.9.0.0";
    ports = [
      "10.69.0.1:${toString tikaPort}:9998"
    ];
  };
  networking.firewall.interfaces.wg0.allowedTCPPorts = [ tikaPort ];
}
