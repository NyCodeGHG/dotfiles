{ config
, pkgs
, inputs
, lib
, host
, ...
}:
let
  fonts = import ./fonts.nix { inherit pkgs; };
in
{
  users.users.marie = {
    isNormalUser = true;
    extraGroups = [ "networkmanager" "wheel" "podman" "docker" ];
    packages = [ ];
    shell = pkgs.zsh;
  };

  security.sudo.wheelNeedsPassword = false;

  home-manager.users.marie = {
    home = {
      inherit (config.system) stateVersion;
      username = "marie";
      homeDirectory = "/home/marie";
    };

    _module.args = { inherit inputs host; };

    imports = [
      ./apps
      inputs.hyprland.homeManagerModules.default
    ];
    xdg.userDirs.enable = true;
  };

  services.gnome.gnome-keyring.enable = true;

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
