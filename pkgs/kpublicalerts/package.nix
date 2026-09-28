{
  stdenv,
  kdePackages,
  fetchFromGitLab,
  cmake,
  nix-update-script,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "kpublicalerts";
  version = "0-unstable-2026-09-23";

  __structuredAttrs = true;
  strictDeps = true;

  src = fetchFromGitLab {
    domain = "invent.kde.org";
    owner = "utilities";
    repo = "kpublicalerts";
    rev = "2bc349fec84bea0e3fe831627d114edaf7e269ae";
    hash = "sha256-5FXapw+d7PHY6+fCN8A1mEPnJBwILiDh9aKrA3j1IgI=";
  };

  nativeBuildInputs = [
    cmake
    kdePackages.extra-cmake-modules
    kdePackages.wrapQtAppsHook
  ];

  buildInputs = with kdePackages; [
    qtpositioning
    qtlocation
    kcoreaddons
    kirigami
    kitemmodels
    ki18n
    kguiaddons
    knotifications
    kcrash
    kunifiedpush
    kweathercore
    kirigami-addons
    kdbusaddons
  ];

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch=master" ]; };
})
