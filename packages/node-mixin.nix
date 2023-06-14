{ stdenvNoCC, go-jsonnet, jsonnet-bundler, fetchFromGitHub, gnumake, prometheus, job ? "node" }: stdenvNoCC.mkDerivation rec {

  name = "node-mixin";
  src = fetchFromGitHub {
    owner = "prometheus";
    repo = "node_exporter";
    rev = "v1.6.0";
    hash = "sha256-Aw1tdaiyr3wv3Ti3CFn2T80WRjEZaACwotKKJGY9I6Y=";
  };
  sourceRoot = "source/docs/node-mixin";

  nativeBuildInputs = [
    gnumake
    go-jsonnet
    jsonnet-bundler
    prometheus.cli
  ];

  grafonnet-lib = fetchFromGitHub {
    owner = "grafana";
    repo = "grafonnet-lib";
    rev = "38f3358ccad25a53700a71e3e5b9032e12fe2023";
    hash = "sha256-wLzEQ6T7DGHCW/zLNwSfyRbTym65M0UV2ZL4JOKM4bc=";
  };

  prePatch = ''
    substituteInPlace config.libsonnet \
      --replace 'job="node"' 'job="${job}"'
  '';

  preBuild = ''
    mkdir -p vendor/github.com/grafana/grafonnet-lib/
    cp -r ${grafonnet-lib}/grafonnet vendor/github.com/grafana/grafonnet-lib/grafonnet
    cp -r ${grafonnet-lib}/grafonnet-7.0 vendor/github.com/grafana/grafonnet-lib/grafonnet-7.0
  '';

  buildPhase = ''
    runHook preBuild
    export PATH="${prometheus}/bin:$PATH"
    make all
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out
    cp *.yaml $out
    cp -r dashboards_out $out/dashboards
    runHook postInstall
  '';
}
