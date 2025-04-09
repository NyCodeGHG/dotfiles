{ pkgs, config, lib, ... }:
{
  environment.systemPackages = with pkgs; [
    prismlauncher
    heroic
    winetricks
    wineWowPackages.unstable
    sandwine
    protonup-qt
    bubblewrap
    vulkan-tools
    glxinfo
    mangohud
    dualsensectl
    libray
    cemu
  ];

  programs.gamemode.enable = true;
  services.flatpak.enable = true;

  boot.kernelParams = [
    "clearcpuid=514"
  ];

  programs.gamescope.enable = true;

  programs.steam = {
    enable = true;
    localNetworkGameTransfers.openFirewall = true;
    remotePlay.openFirewall = true;
  };
  # Fixes Hogwarts Legacy to not crash
  boot.kernel.sysctl."vm.max_map_count" = 2146483642;

  programs.alvr = {
    enable = false;
    openFirewall = true;
  };

  services.sunshine = {
    enable = false;
    autoStart = false;
    openFirewall = true;
    capSysAdmin = true;
  };

  programs.corectrl.enable = true;

  networking.hosts = {
    # fuck you ea
    "127.0.0.1" = [ "winter15.gosredirector.ea.com" ];
  };
}
