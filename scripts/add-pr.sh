#!/usr/bin/env nix-shell
#!nix-shell -i bash -p moreutils jq

set -eoi pipefail

PR="$1"

if [[ -z "$PR" ]]; then
  echo "Usage: add-pr.sh <PR>"
  exit 1
fi

set +e

HASH="$(nix-build \
  --expr \
  "with import <nixpkgs> {}; fetchpatch { url = \"https://github.com/NixOS/nixpkgs/pull/${PR}.diff\"; }" 2>&1 | \
  grep -oP '(?<=got: )sha256-[\w+\/=]{44}')"

set -e

jq ". + { \"${PR}\": \"${HASH}\" }" ./patches/nixpkgs.json | sponge patches/nixpkgs.json
jq "." ./patches/nixpkgs.json

