{
  fetchFromGitHub,
  buildGoModule,
  fetchNpmDeps,
  npmHooks,
  nodejs,
}:

buildGoModule (finalAttrs: {
  pname = "mcp-victorialogs";
  version = "1.9.0";

  src = fetchFromGitHub {
    owner = "VictoriaMetrics";
    repo = "mcp-victorialogs";
    tag = "v${finalAttrs.version}";
    hash = "sha256-esfd6Eg1j2BCgee1T5tiIdSPWVEBqhI4UGDKRFYyn3s=";
  };

  nativeBuildInputs = [
    nodejs
    npmHooks.npmConfigHook
  ];

  preBuild = ''
    env -C web npm run build
  '';

  npmRoot = "web";
  npmDeps = fetchNpmDeps {
    src = "${finalAttrs.src}/web";
    inherit (finalAttrs)
      pname
      version
      ;
    hash = "sha256-B8kEHH7vv1Mp1gLwsFLaFkUyNZsq2ZZHH9U6+a7JlOA=";
  };

  ldflags = [
    "-s"
    "-w"
    "-X=main.version=${finalAttrs.version}"
  ];

  vendorHash = null;

  env = {
    CGO_ENABLED = "0";
  };

  meta.mainProgram = "mcp-victorialogs";
})
