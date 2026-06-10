#!/usr/bin/env nix-shell
#!nix-shell -i bash -p moreutils jq

set -eoi pipefail

PR="$1"

if [[ -z "$PR" ]]; then
  echo "Usage: remove-pr.sh <PR>"
  exit 1
fi

jq "del(.\"$PR\")" ./patches/nixpkgs.json | sponge patches/nixpkgs.json
jq "." ./patches/nixpkgs.json

