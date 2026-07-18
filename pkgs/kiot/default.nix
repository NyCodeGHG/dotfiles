{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  ninja,
  bluez-qt,
  extra-cmake-modules,
  kcmutils,
  kconfig,
  kcoreaddons,
  kdbusaddons,
  kglobalaccel,
  ki18n,
  kidletime,
  knotifications,
  pkg-config,
  pulseaudio-qt,
  qtbase,
  qtdeclarative,
  qtmqtt,
  solid,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "kiot";
  version = "0-unstable-2026-07-01";

  __structuredAttrs = true;
  strictDeps = true;

  src = fetchFromGitHub {
    owner = "davidedmundson";
    repo = "kiot";
    rev = "4dd87c8c886c52dfab3ba76aa9d0988dd2ffc20b";
    hash = "sha256-vsY0Msg96q5GN/XiD4Mo5GWmVucXxPcYmKC4CfA5DmA=";
  };

  dontWrapQtApps = true;

  buildInputs = [
    bluez-qt
    extra-cmake-modules
    kcmutils
    kconfig
    kcoreaddons
    kdbusaddons
    kglobalaccel
    ki18n
    kidletime
    knotifications
    pulseaudio-qt
    qtbase
    qtdeclarative
    qtmqtt
    solid
  ];

  nativeBuildInputs = [
    cmake
    ninja
    pkg-config
  ];

  meta = {
    description = "KDE Home Assistant integration via MQTT";
    homepage = "https://github.com/davidedmundson/kiot";
    license = lib.licenses.lgpl21Plus;
    mainProgram = "kiot";
    maintainers = with lib.maintainers; [ marie ];
  };
})
