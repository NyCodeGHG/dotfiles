{
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  zlib,
  expat,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "overpass";
  version = "0.7.62.4";

  src = fetchFromGitHub {
    owner = "drolbr";
    repo = "Overpass-API";
    tag = "osm3s_v${finalAttrs.version}";
    hash = "sha256-KVjNzLjvMkm8odpUaMY/7LCGviFLP8lchqZkEekaX/M=";
  };

  sourceRoot = "${finalAttrs.src.name}/src";

  enableParallelBuilding = true;

  nativeBuildInputs = [
    autoreconfHook
  ];

  buildInputs = [
    zlib
    expat
  ];
})
