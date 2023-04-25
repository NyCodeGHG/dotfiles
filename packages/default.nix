{
  config,
  pkgs,
  inputs,
  ...
}: {
  home.packages = with pkgs; [
    bitwarden
  ];
}
