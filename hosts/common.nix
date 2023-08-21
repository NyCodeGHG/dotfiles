{ pkgs, agenix, ... }:
{
  imports = [
    ../users/marie
  ];
  environment.systemPackages = with pkgs; [ 
    agenix 
    lshw 
    pciutils 
    speedtest-cli 
    iw 
    inetutils 
    htop
    neofetch
    nftables
    iptables
    wget
    curl
    vim
  ];
}
