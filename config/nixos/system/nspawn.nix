{ config, lib, pkgs, ... }:
{
  options.uwumarie.profiles.nspawn = lib.mkEnableOption (lib.mdDoc "nspawn container config");
  config = lib.mkIf config.uwumarie.profiles.nspawn {
    # Installing a new system within the nspawn means that the /sbin/init script
    # just needs to be updated, as there is no bootloader.

    system.build.installBootLoader = pkgs.writeScript "install-sbin-init.sh" ''
      #!${pkgs.runtimeShell}
      ${pkgs.coreutils}/bin/ln -fs "$1/init" /sbin/init
    '';

    system.activationScripts.installInitScript = lib.mkForce ''
      ${pkgs.coreutils}/bin/ln -fs $systemConfig/init /sbin/init
    '';

    boot.isContainer = true;
  };
}
