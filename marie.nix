{ config
, pkgs
, inputs
, lib
, host
, ...
}:
let
  fonts = import ./fonts.nix { inherit pkgs; };
  hyprlandEnabled = true;
in
{
  users.users.marie = {
    isNormalUser = true;
    extraGroups = [ "networkmanager" "wheel" "podman" "docker" ];
    packages = [ ];
    shell = pkgs.zsh;
  };

  home-manager.users.marie = {
    home = {
      inherit (config.system) stateVersion;
      username = "marie";
      homeDirectory = "/home/marie";
    };

    _module.args = { inherit inputs host; };

    imports = [
      ./apps
    ] ++ lib.optional hyprlandEnabled inputs.hyprland.homeManagerModules.default;
    xdg.userDirs.enable = true;
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
  programs.zsh.enable = true;
}
