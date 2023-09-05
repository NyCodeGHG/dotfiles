{ pkgs, ... }:
{
  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      "$schema" = "https://starship.rs/config-schema.json";
      palette = "default";
      add_newline = true;
      character = {
        error_symbol = "[󰘧](bold red)";
        success_symbol = "[󰘧](bold purple)";
      };
      continuation_prompt = "[](bright-black) ";
      directory = {
        read_only = " ";
        read_only_style = "red bold dimmed";
        style = "bold";
        truncate_to_repo = false;
      };
      format = "$username[@](white)$hostname$os$directory\n$character";
      hostname = {
        format = "[$hostname]($style) ";
        ssh_only = false;
        ssh_symbol = "󰣀 ";
        style = "purple bold";
      };
      nix_shell = {
        format = "[](black)[$symbol $state]($style)[](black)";
        heuristic = true;
        style = "bold blue bg:black";
        symbol = "";
      };
      os = {
        disabled = false;
        format = "[](black)$symbol[](black) ";
        symbols = {
          Android = "[󰀲](bold green bg:black)";
          Debian = "[](bold red bg:black)";
          NixOS = "[](bold blue bg:black)";
        };
      };
      palettes = {
        default = {
          black = "#181818";
          cyan = "#9ee0e0";
          purple = "#aea3ff";
          red = "#ff8585";
          blue = "#70b8ff";
          yellow = "#f3d09b";
          green = "#87c591";
          white = "#f4f4f5";
        };
      };
      right_format = "$nix_shell";
      username = {
        format = "[$user]($style)";
        show_always = true;
        style_root = "red bold";
        style_user = "blue bold";
      };
    };
  };
}
