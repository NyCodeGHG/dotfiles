{
  pkgs,
  config,
  lib,
  ...
}:
{
  uwumarie.prismlauncher = {
    enable = true;
    package = pkgs.prismlauncher.override {
      jdks = [
        pkgs.jdk21
        pkgs.jdk25
      ];
    };
  };
  environment.systemPackages = with pkgs; [
    heroic
    winetricks
    wineWowPackages.unstable
    sandwine
    protonup-qt
    bubblewrap
    vulkan-tools
    mesa-demos
    mangohud
    dualsensectl
    libray
    cemu
    ryubing
    nexusmods-app-unfree
    xrgears
    oversteer
  ];

  programs.gamemode.enable = true;

  boot.kernelParams = [
    "clearcpuid=514"
  ];

  programs.gamescope.enable = true;

  programs.steam = {
    enable = true;
    extest.enable = true;
    localNetworkGameTransfers.openFirewall = true;
    remotePlay.openFirewall = true;
  };
  # Fixes Hogwarts Legacy to not crash
  boot.kernel.sysctl."vm.max_map_count" = 2146483642;

  programs.corectrl.enable = true;

  networking.hosts = {
    # fuck you ea
    # "127.0.0.1" = [ "winter15.gosredirector.ea.com" ];
  };

  # VR
  services.wivrn = {
    enable = false;
    openFirewall = true;
    defaultRuntime = true;

    autoStart = true;
  };

  programs.alvr = {
    enable = false;
    openFirewall = true;
  };

  services.hardware = {
    openrgb.enable = true;
    openrgb.package = pkgs.openrgb-with-all-plugins;
  };
}
