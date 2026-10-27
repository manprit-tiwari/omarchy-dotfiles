#!/usr/bin/env bash
# Is this machine's Claude Code setup the shared one? Read-only. Run on both machines; outputs should match.
#   bash ~/dotfiles/check-claude-setup.sh
set -u
FB="$HOME/Work/FoodBridge"; WS="$FB/foodbridge-claude-workspace"; fails=0
ok()   { printf '  \033[32mPASS\033[0m %s\n' "$*"; }
bad()  { printf '  \033[31mFAIL\033[0m %s\n' "$*"; fails=$((fails + 1)); }
warn() { printf '  \033[33mWARN\033[0m %s\n' "$*"; }
t()    { local msg=$1; shift; if "$@" >/dev/null 2>&1; then ok "$msg"; else bad "$msg"; fi; }
linked() { [[ -L $1 && $(readlink "$1") == *dotfiles/claude/.claude/* ]]; }

echo "Config (dotfiles)"
for f in CLAUDE.md settings.json statusline-command.sh hooks/brain-sync.sh hooks/compact-context.sh hooks/herdr-agent-state.sh; do
  t "~/.claude/$f -> dotfiles" linked "$HOME/.claude/$f"
done
git -C ~/dotfiles fetch -q 2>/dev/null
t "dotfiles claude/ has no local edits" test -z "$(git -C ~/dotfiles status --porcelain -- claude)"
t "dotfiles up to date with origin" test "$(git -C ~/dotfiles rev-list --count HEAD..@{u} 2>/dev/null)" = 0
python3 - "$HOME/.claude/settings.json" <<'PY' || fails=$((fails + 1))
import json, sys
s = json.load(open(sys.argv[1])); e = s.get("env", {})
want = {"autoCompactEnabled": True, "autoCompactWindow": 250000, "autoMemoryDirectory": "~/second-brain",
        "effortLevel": "medium", "permissions.defaultMode": "auto",
        "env.BASH_MAX_OUTPUT_LENGTH": "15000", "env.ANTHROPIC_DEFAULT_HAIKU_MODEL": "claude-haiku-5-5"}
bad = 0
for k, v in want.items():
    got = s
    for part in k.split("."): got = got.get(part) if isinstance(got, dict) else None
    print(f"  {'PASS' if got == v else 'FAIL'} setting {k} = {got!r}")
    bad += got != v
sys.exit(1 if bad else 0)
PY

echo "Plugins and MCP"
plugins=$(claude plugin list 2>/dev/null)
for p in superpowers typescript-lsp ponytail; do
  st=$(awk -v p="❯ $p@" 'index($0, p) {f = 1} f && /Status/ {print; exit}' <<<"$plugins")
  [[ $st == *enabled* ]] && ok "plugin $p enabled" || bad "plugin $p enabled (${st:-not installed})"
done
t "playwright MCP connected" bash -c 'claude mcp list 2>/dev/null | grep -q "^playwright:.*Connected"'

echo "Second brain"
SB=~/second-brain; host=$(hostname -s)
t "vault cloned" test -d "$SB/.git"
git -C "$SB" fetch -q 2>/dev/null
t "vault has no unpushed commits" test "$(git -C "$SB" rev-list --count @{u}..HEAD 2>/dev/null)" = 0
t "vault index valid (gardener --check)" python3 "$SB/tools/gardener/gardener.py" --check
t "gardener ledger exists for host '$host'" test -f "$SB/.ledger/$host.json"
if [[ -f $SB/.ledger/$host.last-run ]]; then ok "gardener last ran $(cat "$SB/.ledger/$host.last-run")"; else warn "gardener has not finished a run on $host yet (starts with the first session of the day)"; fi
t "brain-sync pull runs clean" test -z "$(bash ~/.claude/hooks/brain-sync.sh pull 2>&1)"
[[ $(uname) == Darwin ]] && t "Mac hostname fixed (manprit-mac)" test "$(scutil --get LocalHostName)" = manprit-mac

echo "Tools"
for c in git gh python3 node npx flock docker; do t "$c installed" command -v "$c"; done
t "gh logged in" gh auth status
t "docker running" docker info

echo "Workspace"
t "workspace cloned" test -d "$WS/.git"
t "workspace on main" test "$(git -C "$WS" branch --show-current)" = main
t "6 fb-* agents" test "$(ls "$WS"/.claude/agents/fb-*.md 2>/dev/null | wc -l | tr -d ' ')" = 6
t "skills bugfix + feature" test -f "$WS/.claude/skills/bugfix/SKILL.md" -a -f "$WS/.claude/skills/feature/SKILL.md"
t "TypeScript 5 for LSP" test -f "$WS/node_modules/typescript/lib/tsserver.js"
t "no hard-coded /home/manprit in tools" bash -c "! grep -rqs --exclude-dir=.state '/home/manprit' '$WS/tools' '$WS/lanes' '$WS/.claude'"
for r in cafex-backend cafex-repo cafex-admin storefront-frontend storefront-client-lib frontend-client-lib; do
  [[ -d $FB/$r/.git ]] || { bad "$r cloned"; continue; }
  t "$r origin/HEAD -> develop" test "$(git -C "$FB/$r" symbolic-ref -q refs/remotes/origin/HEAD)" = refs/remotes/origin/develop
done

echo "Lane prerequisites (needed only to run lanes / E2E)"
pwc=$([[ $(uname) == Darwin ]] && echo ~/Library/Caches/ms-playwright || echo ~/.cache/ms-playwright)
ls -d "$pwc"/chromium_headless_shell-* >/dev/null 2>&1 && ok "Playwright headless Chromium" || warn "no headless Chromium: cd $FB/foodbridge-module-user/development && npx playwright install chromium"
for d in cafex-backend storefront-frontend foodbridge-module-user/development; do
  [[ -d $FB/$d/node_modules ]] && ok "$d/node_modules" || warn "$d/node_modules missing: npm ci there"
done
docker ps --format '{{.Names}}' 2>/dev/null | grep -qx cafex-mongodb && ok "lane 0 Mongo (cafex-mongodb) up" || warn "lane 0 not up: cd $FB/cafex-backend && make dev"

echo; [[ $fails == 0 ]] && echo "All required checks passed on $(hostname -s)." || echo "$fails required check(s) failed on $(hostname -s)."
exit $((fails > 0))
