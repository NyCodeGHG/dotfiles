{
  lib,
  rustPlatform,
  fetchFromForgejo,
  cacert,
  nix-update-script,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "prometheus-mdns-sd";
  version = "0.2.0-unstable-2026-09-29";
  __structuredAttrs = true;

  src = fetchFromForgejo {
    domain = "git.enoent.fr";
    owner = "kernald";
    repo = "prometheus-mdns-sd";
    rev = "f67653eae97cac9de69f267f1ef945e8e292fe40";
    hash = "sha256-Ar8kKr1naqRJ8INBxv7b8Sq3CWFaaVSODapgwI58Ha4=";
  };

  cargoHash = "sha256-jDmxrhxcogAhISyUe1xL1gg2tsOgMqKsrQwp0GqhVQI=";

  nativeCheckInputs = [ cacert ];

  passthru.nix-update-args = [ "--version=branch=main" ];

  meta = {
    description = "";
    homepage = "https://git.enoent.fr/kernald/prometheus-mdns-sd";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ marie ];
    mainProgram = "prometheus-mdns-sd";
  };
})
