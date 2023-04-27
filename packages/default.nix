{
  config,
  pkgs,
  inputs,
  ...
}: {
  home.packages = with pkgs; [
    bitwarden
    libsForQt5.ark
    just

    # Programming Languages
    rustup

    # General Tools
    whois
    file
    dogdns
    xdg-utils
    brightnessctl
    wl-clipboard
  ];
}
