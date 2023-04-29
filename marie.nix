{ config
, pkgs
, inputs
, ...
}:
let
  fonts = import ./fonts.nix { inherit pkgs; };
in
{
  users.users.marie = {
    isNormalUser = true;
    extraGroups = [ "networkmanager" "wheel" ];
    packages = [ ];
    shell = pkgs.zsh;
  };

  home-manager.users.marie = {
    home = {
      inherit (config.system) stateVersion;
      username = "marie";
      homeDirectory = "/home/marie";
    };

    _module.args = { inherit inputs; };

    imports = [
      inputs.hyprland.homeManagerModules.default
      ./apps
      ./packages
    ];
  };

  fonts = {
    fonts = fonts.packages;
    fontconfig = {
      defaultFonts = {
        monospace = fonts.monospace ++ fonts.emoji;
        sansSerif = fonts.sansSerif ++ fonts.emoji;
        serif = fonts.serif ++ fonts.emoji;
        emoji = fonts.emoji;
      };
    };
  };

  programs.steam.enable = true;
}
