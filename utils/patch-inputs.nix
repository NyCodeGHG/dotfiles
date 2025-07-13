{
  inputs,
  patches ? _: { },
  hostSystem ? builtins.currentSystem,
  nixpkgs ? inputs.nixpkgs,
}:

let
  pkgsForPatching = import nixpkgs { system = hostSystem; };

  patchFetchers = rec {
    pr =
      repo: id: hash:
      pkgsForPatching.fetchpatch2 {
        url = "https://github.com/${repo}/pull/${builtins.toString id}.diff";
        inherit hash;
      };
    npr = pr "NixOS/nixpkgs";
  };

  fetchedPatches = patches patchFetchers;

  patchInput =
    name: value:
    if (fetchedPatches.${name} or [ ]) != [ ] then
      let
        patchedSrc = pkgsForPatching.applyPatches {
          name = "source-patched";
          src = value;
          patches = fetchedPatches.${name};
        };
      in
      patchedSrc
    else
      value;

  patchedInputs = builtins.mapAttrs patchInput inputs;
in
patchedInputs
