{ inputs, lib, ... }:
{
  imports = [
    inputs.ncro.nixosModules.default
  ];

  services.ncro = {
    enable = true;
    settings = {
      server.listen = ":45976";
      upstreams = [
        {
          url = "https://cache.nixos.org";
          priority = 10;
          public_key = "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY=";
        }
        {
          url = "https://cache.marie.cologne/marie";
          priority = 20;
          public_key = "marie:+lOdb5mtdCgfeh1P+Wsk/7okVYuvlv9eOSyihL6rwPs=";
        }
        {
          url = "https://uwumarie.cachix.org";
          priority = 30;
          public_key = "uwumarie.cachix.org-1:H6nX8e82pu2GQ8CGU3j1qHTG7QMYzZ15oSBh26XhtVo=";
        }
      ];
      logging.timestamps = false;
    };
  };

  nix.settings.substituters = lib.mkForce [ "http://localhost:45976" ];
}
