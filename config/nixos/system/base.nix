{ config, lib, pkgs, inputs, ... }:
{
  options.uwumarie.profiles.base = lib.mkEnableOption (lib.mdDoc "The base config") // {
    default = true;
  };
  config = lib.mkIf config.uwumarie.profiles.base {
    home-manager = {
      useUserPackages = true;
      useGlobalPkgs = true;
      sharedModules = [
        {
          home.stateVersion = lib.mkDefault config.system.stateVersion;
        }
      ];
    };
    environment.systemPackages = with pkgs; [
      htop
      neofetch
      pciutils
      file
      inetutils
      dnsutils
      wget
      curl
      vim
    ];
    programs.nano.enable = false;
  };
}
