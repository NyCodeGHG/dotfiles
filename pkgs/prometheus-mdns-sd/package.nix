{
  lib,
  rustPlatform,
  fetchFromForgejo,
  cacert,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "prometheus-mdns-sd";
  version = "0.2.0-unstable-2026-09-14";
  __structuredAttrs = true;

  src = fetchFromForgejo {
    domain = "git.enoent.fr";
    owner = "kernald";
    repo = "prometheus-mdns-sd";
    rev = "52cfbe4dd585aef4e402937a67894734acebdce5";
    hash = "sha256-gdkkX/Rjtcm4j+KMkgD6/VdxNDDn1znkRxKVwoLVvGw=";
  };

  cargoHash = "sha256-hDyimuSPBuEyqgsdf9z1a5kAgW7nu2sHgtc+nXidsvI=";

  nativeCheckInputs = [ cacert ];

  meta = {
    description = "";
    homepage = "https://git.enoent.fr/kernald/prometheus-mdns-sd";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ marie ];
    mainProgram = "prometheus-mdns-sd";
  };
})
