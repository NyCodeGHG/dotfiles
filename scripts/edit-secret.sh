#!/usr/bin/env bash

set -eou pipefail

FILE="$1"

if [[ -z "$FILE" ]]; then
  echo "Usage: $0 <file>"
  exit 1
fi

hosts_dir=$(realpath "$(dirname "${BASH_SOURCE[0]}")/../hosts")

host_of() {
    local abs rel host
    abs=$(realpath -E "$1")
    rel=${abs#"$hosts_dir"/}
    host=${rel%%/*}

    if [[ ! -d "$hosts_dir/$host" ]]; then
        echo "error: $hosts_dir/$host does not exist." >&2
        exit 1
    fi

    if [[ $rel == "$abs" ]]; then
        echo "error: $1 is not inside a host directory." >&2
        exit 1
    fi

    printf '%s\n' "$host"
}

if [[ -f "$FILE" ]]; then
  exec agenix -i ~/.ssh/id_ed25519 -i /mnt/sata/.ssh/default.ed25519 -i ~/.local/state/agenix/identity.txt -e "$FILE"
fi


RECIPIENTS="$(HOST="$(host_of "$FILE")" \
  nix-instantiate \
    --strict \
    --json \
    --eval \
    -E 'let
          inherit (import <nixpkgs> { }) lib;
          keyNames = [ "marie" (builtins.getEnv "HOST") ];
          keys = import ./keys { inherit lib; };
        in lib.filterAttrs (n: _: lib.elem n keyNames) keys')"

printf "Encrypting new secret in %s for recipients %s\n" \
  "$(realpath -E --relative-base "$(dirname "${BASH_SOURCE[0]}")/.." "$FILE")" \
  "$(jq -r '. | keys | join(", ")' <<< "$RECIPIENTS")"

function cleanup() {
  rm -v "$tempfile"
}

tempfile="$(mktemp -t "age.XXXXXXX")"
trap cleanup EXIT

readarray -t recipientsArgs < <(jq -r '.[] | "-r", .' <<< "$RECIPIENTS")

if [[ -t 0 ]]; then
  echo "Starting $EDITOR"
  $EDITOR "$tempfile" &
  PID="$!"
  wait "$PID"
  AGE_INPUT="$tempfile"
else
  AGE_INPUT="/dev/stdin"
fi
age --encrypt --armor "${recipientsArgs[@]}" < "$AGE_INPUT" -o "$FILE"

