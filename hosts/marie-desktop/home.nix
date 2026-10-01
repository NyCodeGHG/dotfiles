{
  config,
  inputs,
  pkgs,
  ...
}:
{
  imports = [
    inputs.nix-index-database.homeModules.nix-index
  ];
  home.packages = with pkgs; [
    nixvim
    (pkgs.writeShellScriptBin "nvim-vscode" ''
      exec ${pkgs.nixvim-vscode}/bin/nvim "$@"
    '')
  ];
  news.display = "silent";
  uwumarie.profiles = {
    eza = true;
    git = {
      enable = true;
      enableGitEmail = true;
    };
    jujutsu = true;
    ssh.enable = true;
    fish = true;
  };
  age.identityPaths = [
    "${config.home.homeDirectory}/.ssh/agenix.ed25519"
  ];

  programs.atuin = {
    enable = true;
    flags = [ "--disable-up-arrow" ];
    settings = {
      sync_address = "https://atuin.marie.cologne";
      sync.records = true;
    };
  };
  programs.zoxide.enable = true;

  programs.nix-index.enable = true;
}
