{
  stdenv,
  kdePackages,
  fetchFromGitLab,
  cmake,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "kpublicalerts";
  version = "0-unstable-2026-09-06";

  __structuredAttrs = true;
  strictDeps = true;

  src = fetchFromGitLab {
    domain = "invent.kde.org";
    owner = "utilities";
    repo = "kpublicalerts";
    rev = "3ce3d4c35ff70787d50580588baf99327b88b261";
    hash = "sha256-nHnYEaG+ARNmHPZpVj0Dgy8tECJ/Tk6Pf1MGCs25Eyg=";
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
})
