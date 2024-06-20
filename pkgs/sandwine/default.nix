{ lib
, python3Packages
, fetchFromGitHub
, bubblewrap
, util-linux
}:

python3Packages.buildPythonApplication rec {
  pname = "sandwine";
  version = "4.0.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "hartwork";
    repo = "sandwine";
    rev = "refs/tags/${version}";
    hash = "sha256-pH0Zi4yzOvHQI3Q58o6eOLEBbXheFkRu/AzP8felz5I=";
  };

  patches = [ ./Add-nix-binds.patch ];

  postPatch = ''
    substituteInPlace sandwine/_main.py \
      --replace-fail "'bwrap'" "'${lib.getExe bubblewrap}'"
    substituteInPlace sandwine/_main.py \
      --replace-fail "'script'" "'${lib.getExe' util-linux "script"}'"
  '';
  
  build-system = with python3Packages; [ setuptools ];

  dependencies = with python3Packages; [ coloredlogs ];

  meta = {
    description = "Command-line tool to run Windows apps with Wine and bwrap/bubblewrap isolation";
    homepage = "https://github.com/hartwork/sandwine";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ marie ];
    mainProgram = "sandwine";
  };
}
