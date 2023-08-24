{ pkgs, self, ... }:
{
  imports = [
    ../users/marie
  ];
  environment.systemPackages = with pkgs; [ 
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
  ] ++ [
    self.inputs.agenix.packages.${pkgs.system}.default
  ];
}
