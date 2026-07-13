#!/usr/bin/env bash
# Reboot directly into Windows for exactly one boot by setting the UEFI BootNext variable.
# Limine (or any other bootloader) is bypassed for this single reboot only.
#
# Usage: sudo reboot-windows
#        sudo bash ~/dotfiles/limine/reboot-windows.sh

set -euo pipefail

# ---------------------------------------------------------------------------
# 1. Root check
# ---------------------------------------------------------------------------
if (( EUID != 0 )); then
    echo "ERROR: this script must be run as root." >&2
    echo "       Try: sudo $0" >&2
    exit 1
fi

# ---------------------------------------------------------------------------
# 2. Locate the Windows Boot Manager UEFI entry
#
# AUTO-DETECT (default): searches efibootmgr output for "Windows Boot Manager".
#
# MANUAL OVERRIDE: if auto-detect fails, find your ID by running:
#   sudo efibootmgr
# Look for a line like:
#   Boot0002* Windows Boot Manager
# Then uncomment the line below and replace XXXX with your 4-digit hex ID:
#
#   BOOT_NUM="XXXX"
# ---------------------------------------------------------------------------
if [[ -z "${BOOT_NUM:-}" ]]; then
    BOOT_NUM=$(efibootmgr | awk '/\* Windows Boot Manager/{
        match($1, /Boot([0-9A-Fa-f]{4})\*?/, m); print m[1]; exit
    }')

    if [[ -z "$BOOT_NUM" ]]; then
        echo "ERROR: could not auto-detect 'Windows Boot Manager' in efibootmgr output." >&2
        echo "" >&2
        echo "Current UEFI boot entries:" >&2
        efibootmgr 2>&1 | grep -E '^Boot[0-9A-Fa-f]{4}' >&2 || true
        echo "" >&2
        echo "To fix: open this script and hardcode BOOT_NUM near line 30." >&2
        exit 1
    fi

    echo "Detected: Windows Boot Manager → Boot${BOOT_NUM}"
fi

# ---------------------------------------------------------------------------
# 3. Set BootNext (applies only to the next single boot)
# ---------------------------------------------------------------------------
echo "Setting BootNext to ${BOOT_NUM}..."
efibootmgr --bootnext "${BOOT_NUM}"

# ---------------------------------------------------------------------------
# 4. Reboot
# ---------------------------------------------------------------------------
echo "BootNext set. Rebooting into Windows now..."
systemctl reboot
