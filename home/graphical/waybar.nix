{ pkgs
, self
, ...
}: {
  programs.waybar = {
    enable = true;
    package = self.inputs.hyprland.packages.${pkgs.system}.waybar-hyprland;
  };
}
