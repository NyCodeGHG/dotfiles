{ config
, pkgs
, inputs
, ...
}: {
  programs.waybar = {
    enable = true;
    package = inputs.hyprland.packages.${pkgs.system}.waybar-hyprland;
  };
  home.packages = with pkgs; [ inter material-icons ];
}
