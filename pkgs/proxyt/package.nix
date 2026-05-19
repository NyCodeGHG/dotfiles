{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule (finalAttrs: {
  pname = "proxyt";
  version = "0.0.6";

  src = fetchFromGitHub {
    owner = "jaxxstorm";
    repo = "proxyt";
    tag = "v${finalAttrs.version}";
    hash = "sha256-FnTem3EZSEOeG7mh4HgzTl757jgfc7qXPk9YvxVlgKU=";
  };

  vendorHash = "sha256-wdbfcYS3A0c/XDnMxyBOx4pFdMk3FOYQlwTmbS/zMj4=";

  ldflags = [
    "-X=github.com/jaxxstorm/proxyt/cmd.Version=${finalAttrs.version}"
  ];

  meta = {
    description = "";
    homepage = "https://github.com/jaxxstorm/proxyt";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "proxyt";
  };
})
