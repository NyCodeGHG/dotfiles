{ lib
, fetchSteam
, symlinkJoin
, stdenv_32bit
,
}:
let
  appId = "232250";
  server = fetchSteam {
    name = "tf-server";
    inherit appId;
    depotId = "232256";
    manifestId = "794676031397025408";
    hash = "sha256-KmvsyCyRbEeUd9MPL2kmD8o2yE+bRx7Vb4vbWzoWK+A=";
  };
  serverPatched = stdenv_32bit.mkDerivation {
    name = "tf-server-patched";
    src = server;
    installPhase = ''
      runHook preInstall

      mkdir -p $out
      cp -r \
        $src/* \
        $out

      chmod +w $out/srcds_linux
      
      patchelf \
        --set-interpreter "$(cat ${stdenv_32bit.cc}/nix-support/dynamic-linker-m32)" \
        --set-rpath "$out/bin" \
        $out/srcds_linux

      echo "440" > $out/steam_appid.txt
      
      runHook postInstall
    '';
    # Skip phases that don't apply to prebuilt binaries.
    dontBuild = true;
    dontConfigure = true;
    dontFixup = true;
  };
  assets = fetchSteam {
    name = "tf2-assets";
    inherit appId;
    depotId = "232250";
    manifestId = "3243767659984921464";
    hash = "sha256-JOks6929L2m3HfipVZ03tZWVcSATgYHTrbfd7joH3uE=";
  };
in
symlinkJoin {
  name = "tf2-server-full";
  paths = [ serverPatched assets ];
  meta = {
    description = "Team Fortress 2 Dedicated Server.";
    homepage = "https://steamdb.info/app/440/";
    sourceProvenance = with lib.sourceTypes; [
      binaryNativeCode
    ];
    license = lib.licenses.unfree;
    platforms = [ "x86_64-linux" ];
    maintainers = with lib.maintainers; [ marie ];
  };
}
