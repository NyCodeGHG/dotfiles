{ src, version, buildNpmPackage }:
buildNpmPackage {
  pname = "traewelling-web";
  inherit version src;

  npmDepsHash = "sha256-OH669lQdjo3onPkpOcimv/qh//48BPCZqR7y/ueSZBU=";
  npmPackFlags = [ "--ignore-scripts" ];
  npmBuildScript = "production";

  dontFixup = true;

  prePatch = ''
    # delete public directory to only get web output results in this derivation
    rm -rf public
  '';

  installPhase = ''
    runHook preInstall
    cp -r public $out 
    runHook postInstall
  '';
}
