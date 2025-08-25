{
  lib,
  config,
  pkgs,
  ...
}:
{
  options.uwumarie.profiles.graphical = lib.mkEnableOption "graphical profile";
  config = lib.mkIf config.uwumarie.profiles.graphical {
    uwumarie.profiles.audio = true;
    fonts.packages = with pkgs; [
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-color-emoji
      nerd-fonts.jetbrains-mono
    ];

    environment.sessionVariables = {
      "SSH_ASKPASS_REQUIRE" = "prefer";
      "FREETYPE_PROPERTIES" = "cff:no-stem-darkening=0 autofitter:no-stem-darkening=0";
    };

    console = {
      font = "Lat2-Terminus16";
      useXkbConfig = true;
    };

    services = {
      displayManager.sddm = {
        enable = true;
        wayland = {
          enable = true;
          compositor = "kwin";
        };
      };

      orca.enable = false;
      speechd.enable = false;
      xserver.xkb.layout = "de";
      desktopManager.plasma6.enable = true;
    };

    programs.kdeconnect.enable = true;

    programs.ssh = {
      enableAskPassword = true;
      askPassword = lib.getExe pkgs.kdePackages.ksshaskpass;
    };

    systemd.network.enable = lib.mkOverride 800 false;

    boot.kernel.sysctl."vm.swappiness" = 10;

    environment.plasma6.excludePackages = with pkgs.kdePackages; [
      elisa
      kwin-x11
    ];
  };
}
