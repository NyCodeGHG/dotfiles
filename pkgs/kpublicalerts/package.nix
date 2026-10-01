{
  stdenv,
  kdePackages,
  fetchFromGitLab,
  cmake,
  nix-update-script,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "kpublicalerts";
  version = "0-unstable-2026-10-01";

  __structuredAttrs = true;
  strictDeps = true;

  src = fetchFromGitLab {
    domain = "invent.kde.org";
    owner = "utilities";
    repo = "kpublicalerts";
    rev = "2c877b5f368f4a9ef7660291db0f251e4243e456";
    hash = "sha256-nQneWgwq6FW1p4azhEuh8Y4AiwnqGblDmfUKcc+8hBs=";
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

  passthru.nix-update-args = [ "--version=branch=master" ];
})
