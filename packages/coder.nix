{ lib, stdenvNoCC, fetchurl, terraform, autoPatchelfHook, installShellFiles, makeWrapper, ... }:

stdenvNoCC.mkDerivation rec {
  pname = "coder";
  version = "0.23.2";
  src = fetchurl {
    url = "https://github.com/coder/coder/releases/download/v${version}/coder_${version}_linux_amd64.tar.gz";
    sha256 = "sha256:44db95d8045e32b1c5eed255a0312deb7f778e4eee220787abe421f187cf7282";
  };

  sourceRoot = ".";

  nativeBuildInputs = [
    autoPatchelfHook
    installShellFiles
    makeWrapper
  ];

  installPhase = ''
    install -m755 -D coder $out/bin/coder
    installShellCompletion --cmd coder \
      --bash <($out/bin/coder completion bash) \
      --fish <($out/bin/coder completion fish) \
      --zsh <($out/bin/coder completion zsh)
    wrapProgram $out/bin/coder --prefix PATH : ${lib.makeBinPath [ terraform ]}
  '';

  meta = with lib; {
    homepage = "https://coder.com";
    description = "Provision software development environments via Terraform on Linux, macOS, Windows, X86, ARM, and of course, Kubernetes";
    license = licenses.agpl3;
  };
}
