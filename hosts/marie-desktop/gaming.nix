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
    wineWow64Packages.stable
    sandwine
    protonup-qt
    bubblewrap
    vulkan-tools
    mesa-demos
    mangohud
    dualsensectl
    libray
    # cemu
    # ryubing
    xrgears
    # oversteer
    satisfactorymodmanager
    bs-manager
  ];

  services.flatpak.enable = true;

  programs.gamescope.enable = true;

  programs.steam = {
    enable = true;
    extest.enable = true;
    localNetworkGameTransfers.openFirewall = true;
    remotePlay.openFirewall = true;
  };
  # Fixes Hogwarts Legacy to not crash
  # boot.kernel.sysctl."vm.max_map_count" = 2146483642;

  programs.corectrl.enable = true;

  networking.hosts = {
    # fuck you ea
    # "127.0.0.1" = [ "winter15.gosredirector.ea.com" ];
  };

  # VR
  # services.wivrn = {
  #   enable = false;
  #   openFirewall = true;
  #   defaultRuntime = true;
  #
  #   autoStart = true;
  # };

  services.lact.enable = true;
  hardware.amdgpu.overdrive.enable = true;

  programs.alvr = {
    enable = false;
    openFirewall = true;
  };

  services.hardware = {
    openrgb.enable = true;
    openrgb.package = pkgs.openrgb-with-all-plugins;
  };

  security.rtkit.enable = true;

  services.moonshine = {
    enable = true;
    user = "marie";
    extraPackages = [ config.programs.xwayland.package ];
    settings = {
      name = "marie-desktop";
      address = "::";
      application = [
        {
          title = "Steam";
          command = [
            "${lib.getExe config.programs.steam.package}"
            "steam://open/bigpicture"
          ];
        }
      ];
      application_scanner = [
        {
          type = "steam";
          library = "$HOME/.local/share/Steam";
          command = [
            "${lib.getExe config.programs.steam.package}"
            "-bigpicture"
            "steam://rungameid/{game_id}"
          ];
        }
        {
          type = "desktop";
          directories = [
            "$HOME/.local/share/applications"
            "$HOME/.local/share/flatpak/exports/share/applications"
            "/run/current-system/sw/share/applications"
          ];
          include_terminal = false;
          resolve_icons = true;
        }
      ];
    };
    firewallInterfaces = [
      "tailscale0"
      "enp14s0"
      "wlan0"
    ];
  };
}
