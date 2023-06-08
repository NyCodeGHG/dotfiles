(import ./lib.nix) {
  name = "reverse-proxy";

  nodes.machine = { lib, pkgs, ... }: {
    imports = [
      ../modules/reverse-proxy.nix
    ];
    services.nginx.enable = true;
    uwumarie.reverse-proxy = {
      enable = true;
      commonOptions = {
        forceSSL = true;
        sslCertificate = "${pkgs.path}/nixos/tests/common/acme/server/acme.test.cert.pem";
        sslCertificateKey = "${pkgs.path}/nixos/tests/common/acme/server/acme.test.key.pem";
      };
      services."_" = {
        locations."/" = {
          proxyPass = "http://localhost:1337";
        };
      };
    };
  };

  testScript = ''
    machine.start()
    machine.wait_for_open_port(80)
    output = machine.succeed("curl -I http://localhost")
    assert "HTTP/1.1 301 Moved Permanently" in output, 'No 301 redirection was found'
    assert "Location: https://localhost" in output, 'No https redirection'
  '';
}
