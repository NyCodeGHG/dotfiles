{
  config,
  pkgs,
  inputs,
  ...
}:

let
  makeTarball = pkgs.callPackage (pkgs.path + "/nixos/lib/make-system-tarball.nix");
in

{
  boot.postBootCommands = ''
    # After booting, register the contents of the Nix store in the Nix
    # database.

    if [ -f /nix-path-registration ]; then
      ${config.nix.package.out}/bin/nix-store --load-db < /nix-path-registration &&
      rm /nix-path-registration
    fi
  '';

  system.build.tarball = makeTarball {
    extraArgs = "--owner=0";

    storeContents = [
      {
        object = config.system.build.toplevel;
        symlink = "/nix/var/nix/profiles/system";
      }
    ];

    contents = [
      {
        # systemd-nspawn requires this file to exist
        source = config.system.build.toplevel + "/etc/os-release";
        target = "/etc/os-release";
      }
      {
        source = inputs.self;
        target = "/etc/nixos";
      }
    ];

    extraCommands = pkgs.writeScript "extra-commands" ''
      mkdir -p proc sys dev sbin
      ln -sf /nix/var/nix/profiles/system/init sbin/init
    '';
  };
}
