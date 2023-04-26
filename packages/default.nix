{
  config,
  pkgs,
  inputs,
  ...
}: {
  home.packages = with pkgs; [
    bitwarden
    libsForQt5.ark
    neofetch
    hyfetch
  ];
}
