{
  stdenv,
  kdePackages,
  fetchFromGitLab,
  cmake,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "kpublicalerts";
  version = "0-unstable-2026-09-10";

  __structuredAttrs = true;
  strictDeps = true;

  src = fetchFromGitLab {
    domain = "invent.kde.org";
    owner = "utilities";
    repo = "kpublicalerts";
    rev = "b04b8e377c117a3b107edaf8674fb3a98ca95025";
    hash = "sha256-vVWnKHaDWTrfyL46WAlz7QH/agI0AB8HwPXmuUkurGI=";
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
