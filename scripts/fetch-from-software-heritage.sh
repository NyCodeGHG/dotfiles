#!/usr/bin/env nix-shell
#!nix-shell -i bash -p curl cacert gnutar gzip jq

if [[ -z "$1" ]]; then
  echo "Usage: $0 <commit revision>"
  exit 1
fi

set -eou pipefail

revision="$1"
directoryId="$(curl -fsSL "https://archive.softwareheritage.org/api/1/revision/$revision" | jq -r '.directory')"
swhId="swh:1:dir:$directoryId"

while [[ "$(curl -fsSL -X POST "https://archive.softwareheritage.org/api/1/vault/flat/$swhId" | jq -r '.status')" != "done" ]]; do
  echo "Tarball is pending.."
  sleep 30
done

downloadUrl="$(curl -fsSL -X POST "https://archive.softwareheritage.org/api/1/vault/flat/$swhId" | jq -r '.fetch_url')"

temp="$(mktemp -d)"
output="$temp/source"
mkdir -p "$output"

trap "rm -rf $output" EXIT
echo "Fetching tarball from $downloadUrl to $output"

curl -fsSL "$downloadUrl" | tar xz -C "$output" --strip-components=1
echo "Adding $output to store"
nix-store --add "$output"
