#!/usr/bin/env nix-shell
#!nix-shell -i bash -p moreutils jq gh

set -eou pipefail

REPO="NixOS/nixpkgs"
PRS="$(jq -r 'keys.[]' patches/nixpkgs.json)"
NIXPKGS_REV="$(jq -r '.nodes[.nodes.root.inputs.nixpkgs].locked.rev' flake.lock)"

function is_pr_merged() {
  PR="$1"
  PR_INFO="$(gh api "repos/$REPO/pulls/$PR")"
  MERGE_COMMIT_SHA="$(jq -r '.merge_commit_sha' <<< "$PR_INFO")"
  if [[ "$MERGE_COMMIT_SHA" != "null" ]]; then
    PR_STATUS="$(gh api "repos/$REPO/compare/$NIXPKGS_REV...$MERGE_COMMIT_SHA" --jq ".status")"

    [[ "$PR_STATUS" != "ahead" ]]
    IS_MERGED=$?
  else
    IS_MERGED=1
  fi

  if [[ $IS_MERGED == 0 ]]; then
    MERGED_TEXT="\e[0;39;48;2;137;87;229mMerged\e[0m"
  else
    MERGED_TEXT="\e[0;39;48;2;218;54;51mNot merged\e[0m"
  fi
  printf "\e]8;;$(jq -r '.html_url' <<< "$PR_INFO")\e\\PR #$PR: $(jq -r '.title' <<< "$PR_INFO")\e]8;;\e\\: $MERGED_TEXT\n"

  return $IS_MERGED
}

for PR in $PRS; do
  if is_pr_merged "$PR"; then
    jq "del(.\"$PR\")" patches/nixpkgs.json | sponge patches/nixpkgs.json
  fi
done
