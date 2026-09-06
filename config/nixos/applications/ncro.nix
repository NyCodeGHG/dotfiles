{
  config,
  inputs,
  lib,
  ...
}:
let
  hosts = {
    "marie-desktop" = "marie-desktop.weasel-gentoo.ts.net:GBdd4S10c05l/EOmur5vitMPf7/CwwW7ssplsf/qnf4=";
  };
in
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
      ]
      ++ lib.pipe hosts [
        (lib.filterAttrs (host: _: host != config.networking.hostName))
        (lib.mapAttrsToList (
          host: key: {
            url = "https://${host}.weasel-gentoo.ts.net:7777";
            priority = 5;
            public_key = key;
          }
        ))
      ];
      logging.timestamps = false;
    };
  };

  nix.settings.substituters = lib.mkForce [ "http://localhost:45976" ];

  environment.etc = lib.mkIf config.services.alloy.enable {
    "alloy/ncro.alloy".text = ''
      scrape_local "ncro" {
        name = "ncro"
        port = 45976
      }
    '';
  };
}
