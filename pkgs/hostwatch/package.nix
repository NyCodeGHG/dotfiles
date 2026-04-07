{
  rustPlatform,
  fetchFromGitHub,
  lib,
  sqlite,
  libpcap,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "hostwatch";
  version = "1.0.13";

  patches = [
    # https://github.com/opnsense/hostwatch/pull/38
    ./0001-Don-t-enable-rusqlite-bundled-feature-unconditionall.patch
  ];

  src = fetchFromGitHub {
    owner = "opnsense";
    repo = "hostwatch";
    tag = finalAttrs.version;
    hash = "sha256-5Z+SL279bCy2QXbndA9SwfF1RellOzj8L/npRAJalEQ=";
  };

  cargoHash = "sha256-K5k6m/xY7zVQwux0LUhdqTWgIxHnXB3RIoKL6Gw7JoM=";

  buildInputs = [
    sqlite
    libpcap
  ];

  env = {
    DEFAULT_OUI_CSV_PATH = "/var/cache/hostwatch/oui.csv";
  };

  # Disable sqlite bundling
  buildNoDefaultFeatures = true;

  meta = {
    description = "Network monitoring application which discovers and tracks hosts on a network";
    homepage = "https://github.com/opnsense/hostwatch";
    license = lib.licenses.bsd2;
    mainProgram = "hostwatch";
    maintainers = with lib.maintainers; [ marie ];
  };
})
