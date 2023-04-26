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
    just

    # Programming Languages
    rustup

    # General Tools
    whois
    file
    dogdns
  ];
}
