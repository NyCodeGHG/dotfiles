{ config, pkgs, ... }:
{
  programs.ghostty = {
    enable = true;
    installBatSyntax = true;
    installVimSyntax = true;
    settings = {
      font-family = [
        "Maple Mono NF"
        "Noto Sans Symbols 2"
      ];
      theme = "Breeze";
      font-size = "16";
      linux-cgroup = "always";
      gtk-wide-tabs = false;
      mouse-scroll-multiplier = "discrete:0.375";
      gtk-titlebar = false;
      gtk-custom-css = toString (
        pkgs.writeText "breeze-colors.css" ''
          @import url("file://${config.xdg.configHome}/gtk-4.0/colors.css");

          @define-color window_bg_color @theme_bg_color_breeze;
          @define-color window_fg_color @theme_fg_color_breeze;
          @define-color view_bg_color @theme_base_color_breeze;
          @define-color view_fg_color @theme_text_color_breeze;
          @define-color headerbar_bg_color @theme_header_background_breeze;
          @define-color headerbar_fg_color @theme_header_foreground_breeze;
          @define-color headerbar_backdrop_color @theme_header_background_backdrop_breeze;
          @define-color popover_bg_color @theme_bg_color_breeze;
          @define-color popover_fg_color @theme_fg_color_breeze;
          @define-color accent_bg_color @theme_selected_bg_color_breeze;
          @define-color accent_fg_color @theme_selected_fg_color_breeze;
        ''
      );
    };
  };

  xdg.configFile."systemd/user/graphical-session.target.wants/app-com.mitchellh.ghostty.service".source =
    "${config.programs.ghostty.package}/share/systemd/user/app-com.mitchellh.ghostty.service";
}
