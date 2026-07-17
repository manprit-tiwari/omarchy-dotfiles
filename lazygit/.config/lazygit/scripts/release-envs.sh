#!/bin/bash
# Outputs available environments from .release-tag in current repo.
# Empty output = no config found (lazygit will show "no items").
REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null) || exit 0
CONFIG="$REPO_ROOT/.release-tag"
[ -f "$CONFIG" ] || exit 0
grep "^envs=" "$CONFIG" 2>/dev/null | cut -d= -f2- | tr ',' '\n' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//'
