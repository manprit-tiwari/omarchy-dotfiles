#!/usr/bin/env bash
# Sync the second-brain vault with its git remote. Usage: brain-sync.sh pull|push
# Runs from SessionStart (pull) and SessionEnd (push). Never blocks a session.
set -u
vault="$HOME/second-brain"
cd "$vault" 2>/dev/null || exit 0

# One sync at a time per machine (parallel sessions). macOS: brew install flock.
if command -v flock >/dev/null; then
  exec 9>"${TMPDIR:-/tmp}/second-brain-sync.lock"
  flock -w 30 9 || exit 0
fi

pull() {
  git pull -q --rebase --autostash >/dev/null 2>&1 && return 0
  git rebase --abort >/dev/null 2>&1
  echo "second-brain: git pull failed in $vault (conflict or offline); local notes kept, resolve with git there."
}

case "${1:-}" in
  pull)
    pull
    # stow links can be replaced by plain files if a tool rewrites them
    for f in "$HOME/.claude/settings.json" "$HOME/.claude/CLAUDE.md"; do
      [ -e "$f" ] && [ ! -L "$f" ] && echo "dotfiles: $f is no longer a symlink into ~/dotfiles; copy it back and re-run stow."
    done
    ;;
  push)
    git add -A
    git diff --cached --quiet || git commit -qm "brain: $(hostname -s) $(date '+%F %T')"
    pull >&2
    git push -q >/dev/null 2>&1 || echo "second-brain: push failed; will retry next session." >&2
    ;;
esac
exit 0
