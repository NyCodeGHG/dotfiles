{
  config,
  lib,
  pkgs,
  ...
}:
let
  rebootScript = pkgs.writeShellScriptBin "reboot-to-windows" ''
    ${lib.getExe pkgs.kdePackages.kdialog} --title "Reboot into Windows?" --yesno "Are you sure you want to reboot into Windows?" \
      && systemctl reboot --boot-loader-entry=auto-windows
  '';
in
{
  options.programs.switch-to-windows.enable = lib.mkEnableOption "Reboot into windows desktop entry";
  config = lib.mkIf config.programs.switch-to-windows.enable {
    xdg.desktopEntries.switch-to-windows = {
      name = "Reboot to Windows";
      exec = (lib.getExe rebootScript);
      terminal = false;
      categories = [ "System" ];
      icon = pkgs.fetchurl {
        url = "https://upload.wikimedia.org/wikipedia/commons/8/87/Windows_logo_-_2021.svg";
        hash = "sha256-D2t02Njt4ewORUs8b837pl++mJr5pJrU/wxJj03Dr7s=";
      };
    };
    home.packages = [ rebootScript ];
  };
}
