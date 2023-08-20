{ tf2-server-unwrapped
, writeShellScriptBin
, symlinkJoin
, steam-run
, steamcmd
,
}:
symlinkJoin {
  name = "tf2-server";
  paths = [
    tf2-server-unwrapped
    steamcmd
    (writeShellScriptBin "tf2-server"
      ''
        export LD_LIBRARY_PATH="${tf2-server-unwrapped}:${tf2-server-unwrapped}/bin:${tf2-server-unwrapped}/tf/bin:${tf2-server-unwrapped}/share/steamcmd/linux32/"
        exec ${steam-run}/bin/steam-run ${tf2-server-unwrapped}/srcds_run "$@"
      '')
  ];

  inherit (tf2-server-unwrapped) meta;
}
