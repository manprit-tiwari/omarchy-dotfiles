#!/usr/bin/env bash
# SessionStart (matcher "compact"): after a compaction, re-inject the durable state of THIS session's
# feature, so nothing important depends on the summary. The plan is the last `docs/features/<x>/PLAN.md`
# this session's own transcript mentions (hook input: transcript_path). A session that never touched a
# plan gets nothing — never another session's plan. Bounded output (~60 lines).
set -u
input=$(cat)
transcript=$(python3 -c 'import json,sys; print(json.loads(sys.argv[1]).get("transcript_path",""))' "$input" 2>/dev/null)
root=${CLAUDE_PROJECT_DIR:-$PWD}
[[ -f $transcript ]] || exit 0
rel=$(grep -o 'docs/features/[A-Za-z0-9._-]*/PLAN\.md' "$transcript" | grep -v /_TEMPLATE/ | tail -1)
[[ -n $rel && -f $root/$rel ]] || exit 0
plan=$root/$rel
echo "## Re-injected after compaction: this session's plan $rel"
echo "Source of truth for decisions, commits and status — re-read the full file before acting on details."
echo
awk '/^## /{exit} {print}' "$plan" | head -12
echo
awk '/^## 0\./{f=1} f&&/^## /&&!/^## 0\./{exit} f' "$plan" | head -25
echo
echo "### Build log (last rows)"
awk '/^## Build log/{f=1;next} f&&/^## /{exit} f&&/^\|/' "$plan" | tail -8 | cut -c1-400
# anything written after the build log (release notes, latest status)
tail_start=$(awk '/^## Build log/{f=1;next} f&&/^## /{print NR; exit}' "$plan")
[[ -n $tail_start ]] && { echo; echo "### After the build log"; tail -n +"$tail_start" "$plan" | tail -15 | cut -c1-400; }
exit 0
