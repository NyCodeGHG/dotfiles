{ pkgs, config, lib, ... }:
{
  disabledModules = [
    "services/video/wivrn.nix"
  ];
  imports = [
    ./wivrn.nix
  ];
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
    enable = false;
    openFirewall = true;
  };

  services.sunshine = {
    enable = true;
    autoStart = false;
    openFirewall = true;
    capSysAdmin = true;
  };

  programs.corectrl.enable = true;

  nixpkgs.overlays = [(final: prev: {
    wivrn = final.qt6Packages.callPackage ../../pkgs/wivrn/package.nix { };
  })];
  services.wivrn = {
    enable = false;
    defaultRuntime = true;
    openFirewall = true;
    config = {
      enable = true;
      json = {
        scale = 0.8;
        bitrate = 40000000;
        encoders = [
          {
            encoder = "x264";
            codec = "h264";
          }
        ];
      };
    };
  };
}
