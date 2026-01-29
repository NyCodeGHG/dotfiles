{
  lib,
  pkgs,
  inputs,
  config,
  ...
}:
let
  config' = config;
  mkNixPak = inputs.nixpak.lib.nixpak {
    inherit pkgs lib;
  };
  prismlauncher' = mkNixPak {
    config =
      { sloth, config, ... }:
      {
        etc.sslCertificates.enable = true;
        dbus.policies = {
          "${config.flatpak.appId}" = "own";
          "${config.flatpak.appId}.*" = "own";
          "org.freedesktop.DBus" = "talk";
          "org.gtk.vfs.*" = "talk";
          "org.gtk.vfs" = "talk";
          "ca.desrt.dconf" = "talk";
          "org.freedesktop.portal.*" = "talk";
          "org.a11y.Bus" = "talk";
        };
        gpu = {
          enable = true;
          provider = "nixos";
        };
        app.package = config'.uwumarie.prismlauncher.package;
        flatpak.appId = "org.prismlauncher.PrismLauncher";
        bubblewrap = {
          bind.rw = [
            sloth.xdgDownloadDir
            (sloth.concat' sloth.homeDir "/.ftba")
            (sloth.concat' sloth.homeDir "/.local/share/PrismLauncher")
            "/sys/kernel/mm/hugepages"
            "/sys/kernel/mm/transparent_hugepage"
            [
              sloth.appCacheDir
              sloth.xdgCacheHome
            ]
            (sloth.concat' sloth.xdgCacheHome "/fontconfig")
            (sloth.concat' sloth.xdgCacheHome "/mesa_shader_cache")
            (sloth.concat' sloth.xdgCacheHome "/mesa_shader_cache_db")
            (sloth.concat' sloth.xdgCacheHome "/radv_builtin_shaders")

            (sloth.concat' sloth.runtimeDir "/at-spi/bus")
            (sloth.concat' sloth.runtimeDir "/gvfsd")
            (sloth.concat' sloth.runtimeDir "/dconf")
            (sloth.concat' sloth.runtimeDir "/doc")
            (sloth.concat' sloth.runtimeDir "/discord-ipc-0")
          ];
          bind.ro = [
            (sloth.concat' sloth.xdgConfigHome "/gtk-2.0")
            (sloth.concat' sloth.xdgConfigHome "/gtk-3.0")
            (sloth.concat' sloth.xdgConfigHome "/gtk-4.0")
            (sloth.concat' sloth.xdgConfigHome "/fontconfig")
            (sloth.concat' sloth.xdgConfigHome "/dconf")
            (sloth.concat' sloth.xdgConfigHome "/kdeglobals")
          ];
          sockets = {
            wayland = true;
            x11 = true;
            pulse = true;
          };
          network = true;
          bind.dev = [ "/dev/input" ];
        };
      };
  };
in
{
  options.uwumarie.prismlauncher = {
    enable = lib.mkEnableOption "prismlauncher";
    package = lib.mkPackageOption pkgs "prismlauncher" { };
  };
  config = lib.mkIf config.uwumarie.prismlauncher.enable {
    environment.systemPackages = [ prismlauncher'.config.env ];
  };
}
