{
  appimageTools,
  fetchurl,
  lib,
  writeShellApplication,
  curl,
  gnugrep,
  gnused,
  nix-update,
}:

appimageTools.wrapType2 (finalAttrs: {
  pname = "epic-games-launcher";
  version = "0.95.2+gfa9ad49";

  src = fetchurl {
    url = "https://content-download-egs.distro.on.epicgames.com/Builds/EGLv2/${lib.escapeURL finalAttrs.version}/Linux/EpicGamesLauncher-x86_64.AppImage";
    hash = "sha256-cGYVnsmHr83CcGnwcLRWvbmoBb1fAhFKp62G5VWcv9U=";
  };

  passthru.updateScript = lib.getExe (writeShellApplication {
    name = "epic-games-launcher-update";
    runtimeInputs = [
      curl
      gnugrep
      gnused
      nix-update
    ];
    text = ''
      NEW_VERSION="$(curl \
        -I \
        -w '%header{location}' \
        "https://launcher-public-service-prod06.ol.epicgames.com/launcher/api/installer/download/EpicGamesLauncher-x86_64.AppImage" \
        | grep -oP '(?<=EGLv2/)\d+\.\d+\.\d+[^/]*' \
        | sed 's/%2B/+/g'
      )"
      nix-update epic-games-launcher --version "$NEW_VERSION"
    '';
  });

  meta = {
    description = "Game launcher from Epic Games";
    homepage = "https://launcher.epicgames.com/";
    license = lib.licenses.unfree;
  };
})
