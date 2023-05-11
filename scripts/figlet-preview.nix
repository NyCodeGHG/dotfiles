{ pkgs, config, lib, runCommand, figlet, python3, makeWrapper, bash, ... }:
runCommand
{
  name = "figlet-preview";
  nativeBuildInputs = [ makeWrapper ];
} ''
  mkdir -p $out/bin
  cp ${./figlet-preview.py} $out/bin/figlet-preview
  wrapProgram $out/bin/figlet-preview \
    --prefix PATH : ${lib.makeBinPath [ bash figlet python3 ]}
''
