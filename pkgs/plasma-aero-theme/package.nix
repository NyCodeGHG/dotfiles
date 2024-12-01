{
  lib,
  fetchFromGitLab,
  stdenv,
  cmake,
  pkg-config,
  kdePackages,
}:
let
  src = fetchFromGitLab {
    domain = "gitgud.io";
    owner = "wackyideas";
    repo = "aerothemeplasma";
    rev = "2b0f425c44942ebd9b42e338b90ad4af7833a8f4";
    hash = "sha256-TI8ukqWh7gUsttdHxes7e3lWMf+PQ9HWeOUNZE9112s=";
  };
  version = "0-unstable-2024-12-02";
  breeze = stdenv.mkDerivation (finalAttrs: {
    pname = "plasma-aero-theme-breeze";
    inherit src version;

    sourceRoot = "${finalAttrs.src.name}/kwin/decoration/breeze-v5.93.0";
    nativeBuildInputs = [ cmake kdePackages.extra-cmake-modules ];
    # CoreAddons ColorScheme Config GuiAddons I18n IconThemes WindowSystem
    buildInputs = with kdePackages; [
      qtbase
      wrapQtAppsHook
      kcoreaddons
      kcolorscheme
      kconfig
      kguiaddons
      ki18n
      kiconthemes
      kwindowsystem
      kcmutils
      kdecoration
    ];
  });
  sevenstart = stdenv.mkDerivation (finalAttrs: {
    pname = "plasma-aero-theme-plasmoid-sevenstart";
    inherit version src;

    sourceRoot = "${finalAttrs.src.name}/plasma/plasmoids/src/sevenstart_src";
    nativeBuildInputs = [ cmake pkg-config ] ++ (with kdePackages; [ extra-cmake-modules wrapQtAppsHook ]);

    postPatch = ''
      substituteInPlace "src/CMakeLists.txt" \
        --replace-fail "/usr/include/Plasma" "${lib.getDev kdePackages.libplasma}/include/Plasma" \
        --replace-fail "/usr/include/KF6/KConfigCore" "${lib.getDev kdePackages.kconfig}/include/KF6/KConfigCore" \
        --replace-fail "/usr/include/KF6/KConfig" "${lib.getDev kdePackages.kconfig}/include/KF6/KConfig" \
        --replace-fail "/usr/include/KF6/KCoreAddons" "${lib.getDev kdePackages.kcoreaddons}/include/KF6/KCoreAddons"
    '';

    buildInputs = with kdePackages; [
      kconfig
      kcoreaddons
      ki18n
      ksvg
      kwindowsystem
      libplasma
      qtbase
      qtquickeffectmaker
    ];
  });
  kde-effects-aeroglassblur = stdenv.mkDerivation (finalAttrs: {
    pname = "kwin-effects-aeroglassblur";
    inherit src version;

    sourceRoot = "${finalAttrs.src.name}/kwin/effects_cpp/kde-effects-aeroglassblur";

    nativeBuildInputs = [ cmake ] ++ (with kdePackages; [ extra-cmake-modules wrapQtAppsHook ]);
    buildInputs = with kdePackages; [ kwin qttools ];
  });
  kwin-effect-smodsnap-v2 = stdenv.mkDerivation (finalAttrs: {
    pname = "kwin-effect-smodsnap-v2";
    inherit src version;

    sourceRoot = "${finalAttrs.src.name}/kwin/effects_cpp/kwin-effect-smodsnap-v2";

    nativeBuildInputs = [ cmake ] ++ (with kdePackages; [ extra-cmake-modules wrapQtAppsHook ]);
    buildInputs = with kdePackages; [ qtbase kconfigwidgets kdecoration kwin ];
    cmakeFlags = [
      (lib.cmakeBool "BUILD_KF6" true)
    ];
  });
  smodglow = stdenv.mkDerivation (finalAttrs: {
    pname = "plasma-aero-theme-smodglow";
    inherit src version;

    sourceRoot = "${finalAttrs.src.name}/kwin/effects_cpp/smodglow";
    nativeBuildInputs = [ cmake pkg-config ] ++ (with kdePackages; [ extra-cmake-modules wrapQtAppsHook ]);
    buildInputs = [ breeze ] ++ (with kdePackages; [ qtbase kconfigwidgets kdecoration kwin ]);
    cmakeFlags = [
      (lib.cmakeBool "BUILD_KF6" true)
    ];
  });
in
stdenv.mkDerivation (finalAttrs: {
  pname = "plasma-aero-theme";
  inherit src version;

  propagatedUserEnvPkgs = [
    sevenstart
    kde-effects-aeroglassblur
    kwin-effect-smodsnap-v2
    smodglow
    breeze
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/{plasma,sddm/themes,kwin,sounds,icons,mime}

    mv plasma/smod $out/share
    mv plasma/{desktoptheme,look-and-feel,plasmoids,shells} $out/share/plasma

    mv plasma/sddm/sddm-theme-mod $out/share/sddm/themes
    mv kwin/{effects,tabbox,outline,scripts} $out/share/kwin

    tar xf misc/sounds/Archive.tar.gz -C $out/share/sounds
    tar xf 'misc/icons/Windows 7 Aero.tar.gz' -C $out/share/icons
    tar xf misc/cursors/aero-drop.tar.gz -C $out/share/icons

    mv misc/mimetype $out/share/mime/packages
  '';
})
