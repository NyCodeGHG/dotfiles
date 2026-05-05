{
  lib,
  pkgs,
  ...
}:
{
  uwumarie.profiles = {
    corsair = true;
  };

  fonts = {
    packages = with pkgs; [
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-color-emoji
      nerd-fonts.jetbrains-mono
      nerd-fonts.fira-mono
      nerd-fonts.symbols-only
    ];
    enableDefaultPackages = true;
    fontconfig.defaultFonts = {
      emoji = [ "Noto Color Emoji" ];
      monospace = [ "FiraMono Nerd Font" ];
      sansSerif = [ "Noto Sans" ];
      serif = [ "Noto Serif" ];
    };
    fontconfig.useEmbeddedBitmaps = true;
  };

  console.useXkbConfig = true;

  services = {
    displayManager.plasma-login-manager.enable = true;
    desktopManager.plasma6.enable = true;

    orca.enable = false;
    speechd.enable = false;

    xserver.xkb.layout = "de";
    kmscon.hwRender = true;

    pipewire = {
      enable = true;
      jack.enable = true;
      pulse.enable = true;
      alsa = {
        enable = true;
        support32Bit = true;
      };
    };

    resolved.enable = true;
  };

  programs.kdeconnect.enable = true;

  programs.ssh.enableAskPassword = true;

  systemd.network.enable = lib.mkOverride 800 false;

  boot = {
    plymouth.enable = true;
    consoleLogLevel = 3;
    kernelParams = [ "quiet" ];
    kernel.sysctl."vm.swappiness" = 10;
  };

  networking = {
    networkmanager = {
      enable = true;
      wifi.backend = "iwd";
      connectionConfig."connection.mdns" = 2;
    };
    wireless.iwd.settings.General.Country = "DE";
  };

  environment.plasma6.excludePackages = with pkgs.kdePackages; [
    elisa
    kwin-x11
  ];

  environment.systemPackages = with pkgs.kdePackages; [
    kzones
  ];

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = [ pkgs.mesa.opencl ];
  };

  xdg.portal.xdgOpenUsePortal = true;
}
