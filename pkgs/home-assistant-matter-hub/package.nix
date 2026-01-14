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
  version = "3.0.3";

  src = fetchFromGitHub {
    owner = "t0bst4r";
    repo = "home-assistant-matter-hub";
    tag = "v${finalAttrs.version}";
    hash = "sha256-VfhE+rf3pFtAjKpTTLPmHjByuZuigoT3s3S9muLXtnI=";
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
    hash = "sha256-stIS9Nef2ZWEDKnrCbdA5UwSMvyulLO/mEpQgGldkc4=";
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
    rm -r **/node_modules
    pnpm install --offline --prod --filter-prod home-assistant-matter-hub
    mv node_modules $out/share/
    mv {,$out/share/}apps/home-assistant-matter-hub/node_modules

    # We're not including the whole workspace so these links will be broken
    rm -r $out/share/node_modules/.pnpm/node_modules/@home-assistant-matter-hub

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
