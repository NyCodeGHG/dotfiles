{ pkgs, config, lib, ... }:
{
  environment.systemPackages = with pkgs; [
    prismlauncher
    heroic
    winetricks
    wineWowPackages.staging
    sandwine
    protonup-qt
    bubblewrap
    vulkan-tools
    glxinfo
    mangohud
  ];

  programs.gamemode.enable = true;
  services.flatpak.enable = true;

  boot.kernelParams = [
    "clearcpuid=514"
  ];

  programs.gamescope.enable = true;

  programs.steam = {
    enable = true;
    extraCompatPackages = with pkgs; [
      proton-ge-bin
    ];
    localNetworkGameTransfers.openFirewall = true;
    remotePlay.openFirewall = true;
  };
  # Fixes Hogwarts Legacy to not crash
  boot.kernel.sysctl."vm.max_map_count" = 2146483642;

  programs.alvr = {
    enable = true;
    openFirewall = true;
  };
}
