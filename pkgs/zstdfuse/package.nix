{
  stdenv,
  fetchFromGitHub,
  fuse3,
  zstd,
  lib,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "zstdfuse";
  version = "0.2";

  src = fetchFromGitHub {
    owner = "pjrinaldi";
    repo = "zstdfuse";
    tag = "v${finalAttrs.version}";
    hash = "sha256-TSEgJRnM0BJIhdVcWfP99VVhkKB+R+7AJikHhgC5pqg=";
  };

  buildInputs = [
    fuse3
    zstd
  ];

  buildPhase = ''
    runHook preBuild

    cc -O3 -o zstdmount zstdfuse.c -lfuse3 -lpthread -lzstd

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    install -D -m 755 -t $out/bin zstdmount 

    runHook postInstall
  '';

  meta = {
    description = "Fuse Mount a ZSTD compressed file";
    homepage = "https://github.com/pjrinaldi/zstdfuse";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ marie ];
    mainProgram = "zstdmount";
  };
})
