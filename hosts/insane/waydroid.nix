{ config, lib, pkgs, ... }:
let
  waydroid-ui = pkgs.writeShellScriptBin "waydroid-ui" ''
    set -eo pipefail
    export WAYLAND_DISPLAY=wayland-0
    ${pkgs.weston}/bin/weston \
      -Swayland-1 \
      --width=600 \
      --height=1000 \
      --backend=rdp-backend.so \
      --no-clients-resize \
      $@ &
    WESTON_PID=$!

    export WAYLAND_DISPLAY=wayland-1
    ${pkgs.waydroid}/bin/waydroid show-full-ui &

    wait $WESTON_PID
    waydroid session stop
  '';
in
{
  virtualisation = {
    waydroid.enable = true;
    lxd.enable = true;
  };
  networking.firewall.allowedTCPPorts = [ 3389 8080 8081 ];
  networking.firewall.allowedUDPPorts = [ 3389 ];
  environment.systemPackages = [ waydroid-ui ] ++ (with pkgs; [ freerdp android-tools ]);
}
