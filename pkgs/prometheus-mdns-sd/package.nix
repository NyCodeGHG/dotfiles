{
  lib,
  rustPlatform,
  fetchFromForgejo,
  cacert,
  nix-update-script,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "prometheus-mdns-sd";
  version = "0.2.0-unstable-2026-10-01";
  __structuredAttrs = true;

  src = fetchFromForgejo {
    domain = "git.enoent.fr";
    owner = "kernald";
    repo = "prometheus-mdns-sd";
    rev = "56086920c5ee6839bff8bbe5df4fac7692f31f14";
    hash = "sha256-4KySO2PgSGtPvYhC56UBa5vEj0RVsh0HxRh9JowU8eQ=";
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
