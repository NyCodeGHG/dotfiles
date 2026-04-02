{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  nodejs,
  pnpm_10,
  pnpmConfigHook,
  fetchPnpmDeps,
  makeWrapper,
  moreutils,
  jq,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "home-assistant-matter-hub";
  version = "2.0.36";

  src = fetchFromGitHub {
    owner = "RiDDiX";
    repo = "home-assistant-matter-hub";
    tag = "v${finalAttrs.version}";
    hash = "sha256-rH+21cHoOHZQ4QG5qfQsdL7u/t4I8WoqS+tpZ+8gbtk=";
  };

  pnpmDeps = fetchPnpmDeps {
    nativeBuildInputs = [
      moreutils
      jq
    ];
    inherit (finalAttrs)
      pname
      version
      src
      prePatch
      ;
    fetcherVersion = 3;
    hash = "sha256-CjO2URubT1uAPsOvYsw5vvJjxIk7kFzKI6+4Ylv+P+M=";
  };

  nativeBuildInputs = [
    nodejs
    pnpm_10
    pnpmConfigHook
    makeWrapper
    moreutils
    jq
  ];

  # Required to bypass pnpm tty checks
  env.CI = "true";

  prePatch = ''
    jq 'del(.engines.node)' package.json | sponge package.json
  '';

  buildPhase = ''
    runHook preBuild

    # Upstream builds docs in their CI, but we only need
    # the hub and its workspace dependencies.
    pnpm --filter home-assistant-matter-hub... run build

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/{bin,share/apps/home-assistant-matter-hub}

    # Upstream's build script outputs the final artifact as a tarball,
    # which we can just extract into our package output.
    tar -xf apps/home-assistant-matter-hub/package.tgz \
      --strip-components=1 \
      -C $out/share/apps/home-assistant-matter-hub

    # pnpm can't recursively prune monorepos, so we follow pnpm's
    # recommendation of deleting all node_modules and installing
    # just what we need.
    find -name 'node_modules' -type d -exec rm -rf {} \; || true
    pnpm install --offline --prod --filter-prod home-assistant-matter-hub
    mv node_modules $out/share/
    mv {,$out/share/}apps/home-assistant-matter-hub/node_modules

    rm -rf $out/share/apps/home-assistant-matter-hub/node_modules/@home-assistant-matter-hub

    makeWrapper '${lib.getExe nodejs}' "$out/bin/home-assistant-matter-hub" \
      --add-flags "$out/share/apps/home-assistant-matter-hub/dist/backend/cli.js" \
      --set NODE_ENV production

    runHook postInstall
  '';

  meta = {
    inherit (nodejs.meta) platforms;
    description = "Publish your home-assistant instance using Matter";
    homepage = "https://t0bst4r.github.io/home-assistant-matter-hub/";
    changelog = "https://github.com/t0bst4r/home-assistant-matter-hub/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [
      niklaskorz
    ];
    mainProgram = "home-assistant-matter-hub";
  };
})
