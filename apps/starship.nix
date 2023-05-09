{ pkgs, config, lib, ... }:
{
  programs.starship =
    let
      flavour = "mocha";
      catppuccinPallette = pkgs.fetchFromGitHub
        {
          owner = "catppuccin";
          repo = "starship";
          rev = "3e3e54410c3189053f4da7a7043261361a1ed1bc";
          sha256 = "soEBVlq3ULeiZFAdQYMRFuswIIhI9bclIU8WXjxd7oY=";
        } + /palettes/${flavour}.toml;
    in
    {
      enable = true;
      settings = {
        format = "$username@$hostname $directory$character";
        right_format = "$git_status$git_branch$nix_shell$cmd_duration";
        palette = "catppuccin_${flavour}";
        character = {
          success_symbol = "[♥](pink)";
          error_symbol = "[♥](red)";
        };
        line_break = {
          disabled = true;
        };
        add_newline = false;
        username = {
          show_always = true;
          style_user = "bold pink";
          style_root = "bold red";
          format = "[$user]($style)";
        };
        hostname = {
          ssh_only = false;
          format = "[$hostname]($style)";
          style = "bold sapphire";
        };
        directory = {
          style = "bold lavender";
          truncate_to_repo = false;
        };
        nix_shell = { };
      } // builtins.fromTOML (builtins.readFile catppuccinPallette);
    };
}
