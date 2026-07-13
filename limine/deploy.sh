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
SYSTEMD_USER_DIR="/home/manprit/.config/systemd/user"
GIT_USER="manprit"

if ((EUID != 0)); then
    echo "ERROR: run with sudo." >&2
    exit 1
fi

echo "→ Installing reboot-windows script..."
install -Dm755 "${SCRIPT_DIR}/reboot-windows.sh" /usr/local/bin/reboot-windows
echo "  Installed: /usr/local/bin/reboot-windows"

echo "→ Installing post hooks..."
install -Dm755 "${HOOKS_SRC}/50-windows-entry" "${HOOKS_DST}/50-windows-entry"
install -Dm755 "${HOOKS_SRC}/95-sync-dotfiles" "${HOOKS_DST}/95-sync-dotfiles"
echo "  Installed: ${HOOKS_DST}/50-windows-entry"
echo "  Installed: ${HOOKS_DST}/95-sync-dotfiles"

echo "→ Installing limine-sync systemd user units..."
install -Dm644 "${SCRIPT_DIR}/systemd/limine-sync.path"    "${SYSTEMD_USER_DIR}/limine-sync.path"
install -Dm644 "${SCRIPT_DIR}/systemd/limine-sync.service" "${SYSTEMD_USER_DIR}/limine-sync.service"
chmod +x "${SCRIPT_DIR}/sync.sh"
# Ensure files are owned by the user, not root
chown -R "${GIT_USER}:${GIT_USER}" "${SYSTEMD_USER_DIR}/limine-sync.path" \
                                    "${SYSTEMD_USER_DIR}/limine-sync.service"
# Enable linger so the user service runs even before login (e.g. during boot)
loginctl enable-linger "${GIT_USER}"
# Reload and enable the path unit as the user
runuser -u "${GIT_USER}" -- systemctl --user daemon-reload
runuser -u "${GIT_USER}" -- systemctl --user enable --now limine-sync.path
echo "  Enabled: limine-sync.path (user service)"

echo "→ Applying customizations to ${CONF}..."
bash "${HOOKS_DST}/50-windows-entry"

echo "→ Seeding initial dotfiles snapshot..."
cp "$CONF" "$DOTFILES_CONF"
chown "${GIT_USER}:${GIT_USER}" "$DOTFILES_CONF"

echo ""
echo "✓ Done. Verify with:"
echo "  grep -n 'timeout\|default_entry\|Windows' /boot/limine.conf"
echo ""
echo "  Reboot to test the 5-second countdown and Windows entry in the menu."
