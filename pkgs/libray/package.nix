{
  lib,
  python3Packages,
  fetchFromGitea,
  fetchzip,
  fetchpatch2,
}:

let
  version = "0.0.10";
  src = fetchFromGitea {
    domain = "notabug.org";
    owner = "necklace";
    repo = "libray";
    tag = version;
    hash = "sha256-J71b7B//I23Crnlx/0OA3tRPDgVV0KGdikZ+1N8Jgvo=";
  };
  keys = fetchzip {
    url = "https://archive.org/download/sony-playstation-3-disc-keys/sony-playstation-3-disc-keys.zip";
    hash = "sha256-Me1UflfcthFE6esiXoaxVK8B/3367Wc+uz9mLJAC3Mw=";
    stripRoot = false;
  };
in

python3Packages.buildPythonPackage {
  pname = "libray";
  inherit version src;
  pyproject = true;

  patches = [
    (fetchpatch2 {
      url = "https://notabug.org/necklace/libray/commit/185edde30dd59a442fa6237096b8abbf5a902e9c.patch";
      hash = "sha256-vTcbOTlZAYwmazMUZJU0ZnMp624qTHA12SNfr7cu3zU=";
    })
  ];

  build-system = with python3Packages; [ setuptools ];

  dependencies = with python3Packages; [
    tqdm
    pycryptodome
    requests
    beautifulsoup4
    html5lib
    setuptools
  ];

  preBuild = ''
    cp -r ${keys}/* tools

    python3 ./tools/keys2db.py
  '';

  pythonRelaxDeps = true;

  meta = {
    changelog = "https://notabug.org/necklace/libray/src/${src.rev}/CHANGELOG.md";
    description = "Python application for unencrypting, extracting, repackaging, and encrypting PS3 ISOs";
    homepage = "https://notabug.org/necklace/libray";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ marie ];
    mainProgram = "libray";
  };
}
