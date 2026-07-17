#!/bin/bash
set -e

ENV="$1"
SHA="$2"
REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null) || exit 1
CONFIG="$REPO_ROOT/.release-tag"

FORMAT=$(grep "^format=" "$CONFIG" 2>/dev/null | cut -d= -f2- || true)
[ -z "$FORMAT" ] && { echo "No format= defined in .release-tag"; exit 1; }

TAG=$(echo "$FORMAT" | sed \
    -e "s/{env}/$ENV/g" \
    -e "s/{week}/$(date +%V)/g" \
    -e "s/{year}/$(date +%Y)/g" \
    -e "s/{day}/$(date +%a | tr '[:upper:]' '[:lower:]')/g" \
    -e "s/{HH}/$(date +%H)/g" \
    -e "s/{mm}/$(date +%M)/g")

echo "Creating tag: $TAG"
git tag "$TAG" ${SHA:+"$SHA"}
git push origin "$TAG"
echo "Done! Tag '$TAG' pushed to origin."
