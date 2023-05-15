{ lib
, fetchFromGitHub
, installShellFiles
, makeWrapper
, buildGoModule
, fetchYarnDeps
, fixup_yarn_lock
, pkg-config
, nodejs
, yarn
, nodePackages
, python3
, terraform
}:

buildGoModule rec {
  pname = "coder";
  version = "0.23.2";
  src = fetchFromGitHub {
    owner = pname;
    repo = pname;
    rev = "v${version}";
    hash = "sha256-Adj4zR0qN4e8v9JdB6SFFD1ToUnSx8kgA/29kg1n7Qs=";
  };

  offlineCache = fetchYarnDeps {
    yarnLock = src + "/site/yarn.lock";
    hash = "sha256-2rwbsRUw9yzjJy9efWBVYf9FlitafSsN68hERbRA+xE=";
  };

  vendorHash = "sha256-I3rtkFtuKA86hIfZcodSPD5C185Ftjn6Ic+491ixatU=";

  tags = [ "embed" ];

  ldflags = [
    "-s"
    "-w"
    "-X github.com/coder/coder/buildinfo.tag=${version}"
  ];

  subPackages = [ "cmd/..." ];

  preBuild = ''
    export HOME=$TEMPDIR

    export PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD=1

    pushd site
    yarn config --offline set yarn-offline-mirror ${offlineCache}
    fixup_yarn_lock yarn.lock

    # node-gyp tries to download always the headers and fails: https://github.com/NixOS/nixpkgs/issues/195404
    yarn remove --offline jest-canvas-mock canvas
    # yarn install --offline --frozen-lockfile --ignore-engines --ignore-scripts --no-progress
    patchShebangs node_modules
    
    NODE_ENV=production yarn run --offline typegen
    NODE_ENV=production node node_modules/.bin/vite build

    popd
  '';

  nativeBuildInputs = [
    fixup_yarn_lock
    installShellFiles
    makeWrapper
    nodePackages.node-pre-gyp
    nodejs
    pkg-config
    python3
    yarn
  ];

  postInstall = ''
    installShellCompletion --cmd coder \
      --bash <($out/bin/coder completion bash) \
      --fish <($out/bin/coder completion fish) \
      --zsh <($out/bin/coder completion zsh)

    wrapProgram $out/bin/coder --prefix PATH : ${lib.makeBinPath [ terraform ]}
  '';

  # integration tests require network access
  doCheck = false;

  meta = {
    description = "Provision software development environments via Terraform on Linux, macOS, Windows, X86, ARM, and of course, Kubernetes";
    homepage = "https://coder.com";
    license = lib.licenses.agpl3;
    maintainers = [ lib.maintainers.ghuntley lib.maintainers.urandom ];
  };
}
