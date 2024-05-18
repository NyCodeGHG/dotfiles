{ lib
, rustPlatform
, fetchFromGitHub
}:

rustPlatform.buildRustPackage rec {
  pname = "wgsl-analyzer";
  version = "0.8.1";

  src = fetchFromGitHub {
    owner = "wgsl-analyzer";
    repo = "wgsl-analyzer";
    rev = "v${version}";
    hash = "sha256-bhosTihbW89vkqp1ua0C1HGLJJdCNfRde98z4+IjkOc=";
  };

  cargoLock = {
    lockFile = ./Cargo.lock;
    outputHashes = {
      "la-arena-0.3.1" = "sha256-7/bfvV5kS13zLSR8VCsmsgoWa7PHidFZTWE06zzVK5s=";
      "naga-0.14.0" = "sha256-Wo5WJzi1xdmqx23W1nuIUXkfKEzXVwL+dZu5hBOhHW8=";
    };
  };

  checkFlags = [
    # snapshot files don't seem to be up-to-date
    "--skip=tests::parse_import"
    "--skip=tests::parse_import_colon"
    "--skip=tests::parse_string_import"
    "--skip=tests::struct_recover_3"
  ];

  postInstall = ''
    rm $out/bin/package
  '';

  meta = with lib; {
    description = "A language server implementation for the WGSL shading language";
    homepage = "https://github.com/wgsl-analyzer/wgsl-analyzer";
    changelog = "https://github.com/wgsl-analyzer/wgsl-analyzer/blob/${src.rev}/CHANGELOG.md";
    license = with licenses; [ asl20 mit ];
    maintainers = with maintainers; [ marie ];
    mainProgram = "wgsl-analyzer";
  };
}
