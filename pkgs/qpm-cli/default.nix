{ lib
, rustPlatform
, fetchFromGitHub
, pkg-config
, bzip2
, libgit2
, openssl
, zlib
, zstd
, stdenv
, darwin
}:

rustPlatform.buildRustPackage rec {
  pname = "qpm-cli";
  version = "1.3.0";

  src = fetchFromGitHub {
    owner = "QuestPackageManager";
    repo = "QPM.CLI";
    rev = "v${version}";
    hash = "sha256-w6IYcM1/3XFD5mLYM4pGt8Jqi6dyXgh5mucDF/fcsbs=";
  };

  cargoLock = {
    lockFile = ./Cargo.lock;
    outputHashes = {
      "cursed-semver-parser-0.1.0" = "sha256-T1nXjKpAJtAikJOJwI3+t+beP7iVzSnoIBkYkA1UZx0=";
      "qpm_arg_tokenizer-0.1.0" = "sha256-1bYxmEYfWuWSNPs7TvutNxMjB44ITOtkaM2KvzND/d0=";
      "qpm_package-0.4.0" = "sha256-dz2NqHtqyK7PvrpBNGy8paPqWm+/LJSYF4o93qEg+9k=";
      "qpm_qmod-0.1.0" = "sha256-kFzj8odyXDnHFXPWN9EHBS0g7W1Hb3mcz085E0SWFYw=";
      "templatr-0.1.0" = "sha256-zqQNAjbHG8ytW+B6fM3Hc1WQdRQnX5FnFfRyTW8qmaw=";
    };
  };

  # look away
  env.RUSTC_BOOTSTRAP = "1";

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    bzip2
    libgit2
    openssl
    zlib
    zstd
  ] ++ lib.optionals stdenv.isDarwin [
    darwin.apple_sdk.frameworks.Security
  ];

  env = {
    OPENSSL_NO_VENDOR = true;
    ZSTD_SYS_USE_PKG_CONFIG = true;
  };

  checkFlags = [
    # skip tests which require network
    "--skip=tests::network::qpackages::download_package_binary"
    "--skip=tests::network::qpackages::get_artifact"
    "--skip=tests::network::qpackages::get_artifact_package_versions"
    "--skip=tests::network::qpackages::get_artifact_packages"
    "--skip=tests::network::qpackages::resolve"
    "--skip=tests::network::qpackages::resolve_fail"
  ];

  meta = with lib; {
    description = "QPM command line tool";
    homepage = "https://github.com/QuestPackageManager/QPM.CLI";
    license = licenses.gpl3Only;
    maintainers = with maintainers; [ marie ];
    mainProgram = "qpm-cli";
  };
}
