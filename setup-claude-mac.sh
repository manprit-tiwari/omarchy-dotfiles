#!/usr/bin/env bash
# Same Claude Code setup on the MacBook as on bankai: macOS (manprit-mac) or Omarchy on Apple Silicon (omarchy-m).
# Safe to re-run.
#   git clone git@github.com:manprit-tiwari/omarchy-dotfiles.git ~/dotfiles   (or via https)
#   bash ~/dotfiles/setup-claude-mac.sh
# Config itself is not copied: ~/.claude/{CLAUDE.md,settings.json,statusline,hooks} become symlinks into
# this repo (stow package `claude`), memory is ~/second-brain (git). Edit on either machine, push, pull.
set -euo pipefail
OS=$(uname)

# 1. Tools (flock: brain-sync.sh locks with it)
if [ "$OS" = Darwin ]; then
  HOST=manprit-mac
  command -v brew >/dev/null || /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  eval "$(/opt/homebrew/bin/brew shellenv)"
  brew install git gh stow flock node python jq mongosh
else
  HOST=omarchy-m
  sudo pacman -S --needed --noconfirm git github-cli stow util-linux nodejs npm python jq docker docker-compose
  # Playwright MCP (and chrome-devtools-mcp) use Google Chrome at /opt/google/chrome/chrome; Omarchy's repo ships an arm64 build
  [ -x /opt/google/chrome/chrome ] || sudo pacman -S --needed --noconfirm google-chrome || echo "!! Google Chrome not installed: Playwright MCP needs it"
fi
command -v claude >/dev/null || curl -fsSL https://claude.ai/install.sh | bash
export PATH="$HOME/.local/bin:$PATH"

# 2. GitHub: SSH key + https credential helper (remotes are a mix of both)
gh auth status >/dev/null 2>&1 || gh auth login -p ssh -w
# Linux: register the pacman gh, not mise's versioned path (that breaks the credential helper after a mise upgrade)
if [ "$OS" = Darwin ]; then gh auth setup-git; else /usr/bin/gh auth setup-git; fi
# SSH key exists and is on GitHub (gh login with an existing session skips the upload)
mkdir -p ~/.ssh && chmod 700 ~/.ssh
[ -f ~/.ssh/id_ed25519 ] || ssh-keygen -t ed25519 -N "" -C "$HOST" -f ~/.ssh/id_ed25519
gh ssh-key list 2>/dev/null | grep -qF "$(awk '{print $2}' ~/.ssh/id_ed25519.pub)" || gh ssh-key add ~/.ssh/id_ed25519.pub -t "$HOST"
# GitHub host keys from the API (over authenticated https), so the first git@ clone does not stop at a yes/no prompt
ssh-keygen -F github.com >/dev/null 2>&1 || gh api meta --jq '.ssh_keys[] | "github.com " + .' >> ~/.ssh/known_hosts

# 3. Repos, same paths as Linux (~/Work/FoodBridge/<repo>)
clone() { [ -d "$2" ] || git clone "$1" "$2"; }
clone https://github.com/manprit-tiwari/second-brain.git ~/second-brain

# 3a. Second-brain guards, before any Claude session runs the hooks:
#   - fixed hostname: the gardener's ledger/stamp are per hostname; a drifting name would reprocess everything
#   - baseline: transcripts already on this machine (old ~/Manprit/Foodbridge work) are marked done, never turned into notes
if [ "$OS" = Darwin ]; then
  [ "$(scutil --get LocalHostName 2>/dev/null)" = $HOST ] || for k in ComputerName HostName LocalHostName; do sudo scutil --set $k $HOST; done
else
  [ "$(hostnamectl hostname)" = $HOST ] || sudo hostnamectl hostname $HOST
fi
[ -f ~/second-brain/.ledger/$HOST.json ] || { python3 ~/second-brain/tools/gardener/gardener.py --baseline && \
  git -C ~/second-brain add .ledger && git -C ~/second-brain commit -qm "brain: $HOST baseline" && git -C ~/second-brain push -q; }
FB="$HOME/Work/FoodBridge"; mkdir -p "$FB"
while read -r name url; do clone "$url" "$FB/$name"; done <<'EOF'
foodbridge-claude-workspace https://github.com/manprit-tiwari/foodbridge-claude-workspace.git
cafex-backend git@github.com:exagon-ai/cafex-backend.git
cafex-repo git@github.com:kumarrakesh/cafex-repo.git
cafex-admin git@github.com:exagon-ai/cafex-admin.git
storefront-frontend git@github.com:exagon-ai/storefront-frontend.git
storefront-client-lib git@github.com:nishant-devekar/storefront-client-lib.git
frontend-client-lib git@github.com:exagon-ai/frontend-client-lib.git
accounting-integration git@github.com:exagon-ai/accounting-integration.git
agentic-qa-workspace https://github.com/exagon-ai/agentic-qa-workspace.git
amds-host-session https://github.com/exagon-ai/amds-host-session.git
autocode git@github.com:exagon-ai/autocode.git
client-cms https://github.com/exagon-ai/client-cms-hub.git
foodbridge-cell-registry git@github.com:exagon-ai/foodbridge-cell-registry.git
foodbridge-db-schema-engine git@github.com:exagon-ai/foodbridge-db-schema-engine.git
foodbridge-module-accounting-integration https://github.com/exagon-ai/foodbridge-module-accounting-integration.git
foodbridge-module-analytics https://github.com/exagon-ai/foodbridge-module-analytics.git
foodbridge-module-client-cms https://github.com/exagon-ai/foodbridge-module-client-cms.git
foodbridge-module-customer-stock-audit https://github.com/exagon-ai/foodbridge-module-customer-stock-audit.git
foodbridge-module-digital-assistant git@github.com:exagon-ai/foodbridge-module-digital-assistant.git
foodbridge-module-finance https://github.com/exagon-ai/foodbridge-module-finance.git
foodbridge-module-maintenance git@github.com:exagon-ai/foodbridge-module-maintenance.git
foodbridge-module-production git@github.com:exagon-ai/foodbridge-module-production.git
foodbridge-module-product-management git@github.com:exagon-ai/foodbridge-module-product-management.git
foodbridge-module-purchase https://github.com/exagon-ai/foodbridge-module-purchase.git
foodbridge-module-route-delivery git@github.com:exagon-ai/foodbridge-module-route-delivery.git
foodbridge-module-running-totals git@github.com:exagon-ai/foodbridge-module-running-totals.git
foodbridge-module-settlement git@github.com:exagon-ai/foodbridge-module-settlement.git
foodbridge-module-user https://github.com/exagon-ai/foodbridge-module-user.git
foodbridge-observability git@github.com:exagon-ai/foodbridge-observability.git
foodbridge-pmf git@github.com:exagon-ai/foodbridge-pmf.git
foodbridge-qa-automation https://github.com/exagon-ai/foodbridge-qa-automation.git
foodbridge-user-tracking git@github.com:exagon-ai/foodbridge-user-tracking.git
mongodb-backup-script git@github.com:exagon-ai/mongodb-backup-script.git
retails-overview git@github.com:exagon-ai/retails-overview.git
tally-sync-agent git@github.com:exagon-ai/tally-sync-agent.git
unified_ingestion_platform git@github.com:exagon-ai/unified_ingestion_platform.git
EOF

# 4. Link the Claude config. Existing real files are kept as *.mac-bak.
#    macOS: no systemd, the first Claude session of the day starts the gardener (brain-sync.sh).
#    Omarchy: the 02:00 gardener timer, as on bankai.
mkdir -p ~/.claude/hooks
for f in CLAUDE.md settings.json statusline-command.sh; do
  [ -e ~/.claude/$f ] && [ ! -L ~/.claude/$f ] && mv ~/.claude/$f ~/.claude/$f.mac-bak
done
if [ "$OS" = Darwin ]; then
  stow -d ~/dotfiles -t ~ --no-folding --ignore=systemd claude
else
  stow -d ~/dotfiles -t ~ --no-folding claude
  systemctl --user daemon-reload && systemctl --user enable --now second-brain-gardener.timer
  sudo systemctl enable --now docker && sudo usermod -aG docker "$USER"   # lanes run on docker; group applies after re-login
fi

# 5. Plugins: install all (disabled ones are enabled on demand per CLAUDE.md), then restore the
#    enabled/disabled flags, since `install` writes them into the symlinked settings.json.
claude plugin marketplace add anthropics/claude-plugins-official 2>/dev/null || true
claude plugin marketplace add DietrichGebert/ponytail 2>/dev/null || true
for p in superpowers typescript-lsp frontend-design playwright context7 chrome-devtools-mcp mongodb vercel \
         code-review code-simplifier claude-md-management claude-code-setup postman; do
  claude plugin install "$p@claude-plugins-official" || echo "!! plugin $p failed"
done
claude plugin install ponytail@ponytail || echo "!! plugin ponytail failed"
git -C ~/dotfiles checkout -- claude/.claude/settings.json

# 6. MCP (user scope, as on Linux)
claude mcp get playwright >/dev/null 2>&1 || claude mcp add -s user playwright -- npx @playwright/mcp@latest --isolated

# 7. TypeScript 5 for LSP in the workspace (machine-local, not in git)
TSD="$HOME/.local/share/claude-lsp-typescript"
[ -d "$TSD/node_modules/typescript" ] || npm i --prefix "$TSD" typescript@^5.9.3
mkdir -p "$FB/foodbridge-claude-workspace/node_modules"
ln -sfn "$TSD/node_modules/typescript" "$FB/foodbridge-claude-workspace/node_modules/typescript"

echo
echo "Done. Next: run 'claude' once and /login. Start sessions in $FB/foodbridge-claude-workspace."
ls -l ~/.claude/CLAUDE.md ~/.claude/settings.json ~/.claude/hooks/
