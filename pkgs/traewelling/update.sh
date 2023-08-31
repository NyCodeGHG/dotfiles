#!/usr/bin/env nix-shell
#! nix-shell -i bash -p nix curl jq nix-update

# check if composer2nix is installed
if ! command -v composer2nix &> /dev/null; then
  echo "Please install composer2nix (https://github.com/svanderburg/composer2nix) to run this script."
  exit 1
fi

if [ -z "$1" ]; then
  echo "Please use ./update.sh <revision>"
  exit 1
fi

TARGET_REV=$1

TRAEWELLING=https://github.com/traewelling/traewelling/raw/$TARGET_REV
SHA256=$(nix-prefetch-url --unpack "https://github.com/traewelling/traewelling/archive/$TARGET_REV/traewelling.tar.gz")
SRI_HASH=$(nix hash to-sri --type sha256 "$SHA256")

curl -LO "$TRAEWELLING/composer.json"
curl -LO "$TRAEWELLING/composer.lock"

composer2nix --name "traewelling" \
  --composition=composition.nix \
  --no-dev
rm composer.json composer.lock

# change version number
sed -e "s/version =.*;/version = \"$TARGET_REV\";/g" \
    -e "s/hash =.*;/hash = \"$SRI_HASH\";/g" \
    -i ./default.nix

# nix build .#trawelling
