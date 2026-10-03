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
  kscreen,
  pkg-config,
  pulseaudio-qt,
  qtbase,
  qtdeclarative,
  qtmqtt,
  solid,
  imagemagick,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "kiot";
  version = "0-unstable-2026-09-28";

  __structuredAttrs = true;
  strictDeps = true;

  src = fetchFromGitHub {
    owner = "davidedmundson";
    repo = "kiot";
    rev = "1910297e8f227a9e6c8b9889f7e3417b60277833";
    hash = "sha256-UhqV6zKwR/a8I9XBR2g7MuE6D5+Z+Q0qAP1ANR+HX+A=";
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
    kscreen
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
    imagemagick
  ];

  passthru.nix-update-args = [ "--version=branch=master" ];

  meta = {
    description = "KDE Home Assistant integration via MQTT";
    homepage = "https://github.com/davidedmundson/kiot";
    license = lib.licenses.lgpl21Plus;
    mainProgram = "kiot";
    maintainers = with lib.maintainers; [ marie ];
  };
})
