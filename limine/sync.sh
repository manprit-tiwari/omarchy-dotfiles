#!/usr/bin/env bash
# Copies /boot/limine.conf to dotfiles and commits if changed.
# Runs as manprit via the limine-sync.service user unit.

CONF="/boot/limine.conf"
DOTFILES_DIR="$HOME/dotfiles"
DOTFILES_CONF="$DOTFILES_DIR/limine/limine.conf"

cp "$CONF" "$DOTFILES_CONF" || exit 1

# Nothing to do if the file matches what's already in git
if /usr/bin/git -C "$DOTFILES_DIR" diff --quiet limine/limine.conf 2>/dev/null; then
    exit 0
fi

/usr/bin/git -C "$DOTFILES_DIR" \
    -c commit.gpgsign=false \
    add limine/limine.conf

/usr/bin/git -C "$DOTFILES_DIR" \
    -c commit.gpgsign=false \
    commit -m "chore: sync limine.conf after boot entry update [automated]"
