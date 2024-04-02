{ config, lib, pkgs, inputs, ... }:
{
  options.uwumarie.profiles.base = lib.mkEnableOption (lib.mdDoc "The base config") // {
    default = true;
  };
  config = lib.mkIf config.uwumarie.profiles.base {
    environment.systemPackages = with pkgs; [
      htop
      neofetch
      pciutils
      file
      iputils
      dnsutils
      wget
      curl
      vim
      tcpdump
      git
    ];
    programs.nano.enable = false;
  };
}
