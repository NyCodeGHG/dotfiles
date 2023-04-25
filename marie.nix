{ config, pkgs, inputs, ... }:

{
  users.users.marie = {
    isNormalUser = true;
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [];
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
    fonts = with pkgs; [
      noto-fonts
      noto-fonts-cjk
      noto-fonts-emoji
      (nerdfonts.override { fonts = ["JetBrainsMono" "Iosevka"]; })
    ];
    fontconfig = {
      defaultFonts = {
        monospace = [
          "Iosevka Nerd Font"
          "Noto Color Emoji"
        ];
        sansSerif = ["Noto Sans" "Noto Color Emoji"];
        serif = ["Noto Serif" "Noto Color Emoji"];
        emoji = ["Noto Color Emoji"];
      };
    };
  };
}
