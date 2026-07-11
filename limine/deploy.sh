#!/usr/bin/env bash
# Deploy limine customizations. Run once with sudo after cloning dotfiles on a new machine,
# or after modifying the hooks/ scripts.
#
# Usage: sudo bash ~/dotfiles/limine/deploy.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOOKS_SRC="${SCRIPT_DIR}/hooks"
HOOKS_DST="/etc/boot/hooks/post.d"
CONF="/boot/limine.conf"
DOTFILES_CONF="${SCRIPT_DIR}/limine.conf"

if ((EUID != 0)); then
    echo "ERROR: run with sudo." >&2
    exit 1
fi

echo "→ Installing post hooks..."
install -Dm755 "${HOOKS_SRC}/50-windows-entry" "${HOOKS_DST}/50-windows-entry"
install -Dm755 "${HOOKS_SRC}/95-sync-dotfiles" "${HOOKS_DST}/95-sync-dotfiles"
echo "  Installed: ${HOOKS_DST}/50-windows-entry"
echo "  Installed: ${HOOKS_DST}/95-sync-dotfiles"

echo "→ Applying customizations to ${CONF}..."
bash "${HOOKS_DST}/50-windows-entry"

echo "→ Seeding initial dotfiles snapshot..."
cp "$CONF" "$DOTFILES_CONF"

echo ""
echo "✓ Done. Verify with:"
echo "  grep -n 'timeout\|default_entry\|Windows' /boot/limine.conf"
echo ""
echo "  Reboot to test the 5-second countdown and Windows entry in the menu."
