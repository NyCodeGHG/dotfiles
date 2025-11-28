{
  pkgs,
  inputs,
  config,
  ...
}:
{
  # Use Lix overlay nix
  nix.package = pkgs.nix;
  imports = [
    inputs.hydra.nixosModules.overlayNixpkgsForThisHydra
  ];
  nixpkgs.overlays = [
    (self: super: {
      hydra = super.hydra.override {
        postgresql_13 = config.services.postgresql.package;
      };
    })
  ];
  services.hydra = {
    enable = true;
    hydraURL = "https://hydra.marie.cologne";
    notificationSender = "hydra@marie.cologne";
    buildMachinesFiles = [
      (pkgs.writeText "machines" ''
        ssh://root@gitlabber.weasel-gentoo.ts.net i686-linux,x86_64-linux - 4 2 kvm,nixos-test,big-parallel,benchmark -
      '')
    ];
    useSubstitutes = true;
    port = 3001;
  };

  nix.settings.allowed-uris = [
    "github:"
    "git+https://github.com/"
    "git+ssh://github.com/"
    "git+https://codeberg.org/"
    "git+ssh://codeberg.org/"
  ];

  services.nginx.virtualHosts = {
    "hydra.marie.cologne" = {
      locations."/" = {
        proxyPass = "http://[::1]:3001";
        proxyWebsockets = true;
      };
    };
  };
}
