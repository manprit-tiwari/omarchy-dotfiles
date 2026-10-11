#!/usr/bin/env bash
# Claude Code status line — mirrors a Starship-style prompt

input=$(cat)

# Current directory (shortened: replace $HOME with ~)
cwd=$(echo "$input" | jq -r '.cwd')
cwd_display="${cwd/#$HOME/\~}"

# Git repo (owner/name)
repo=$(echo "$input" | jq -r '.workspace.repo | if . then .owner + "/" + .name else empty end')

# Git worktree (if applicable)
worktree=$(echo "$input" | jq -r '.workspace.git_worktree // empty')

# Model display name
model=$(echo "$input" | jq -r '.model.display_name')

# Context remaining percentage
remaining=$(echo "$input" | jq -r '.context_window.remaining_percentage // empty')

# Rate limit (5-hour session, Claude.ai subscribers)
five_hour=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')

# Build the output
parts=()

# Directory
parts+=("$(printf '\033[34m%s\033[0m' "$cwd_display")")

# Repo
if [ -n "$repo" ]; then
  if [ -n "$worktree" ]; then
    parts+=("$(printf '\033[36m%s (%s)\033[0m' "$repo" "$worktree")")
  else
    parts+=("$(printf '\033[36m%s\033[0m' "$repo")")
  fi
fi

# Model
parts+=("$(printf '\033[33m%s\033[0m' "$model")")

# Context remaining
if [ -n "$remaining" ]; then
  remaining_int=$(printf '%.0f' "$remaining")
  if [ "$remaining_int" -le 10 ]; then
    parts+=("$(printf '\033[31mctx: %s%%\033[0m' "$remaining_int")")
  elif [ "$remaining_int" -le 25 ]; then
    parts+=("$(printf '\033[33mctx: %s%%\033[0m' "$remaining_int")")
  else
    parts+=("$(printf 'ctx: %s%%' "$remaining_int")")
  fi
fi

# Rate limit
if [ -n "$five_hour" ]; then
  five_int=$(printf '%.0f' "$five_hour")
  parts+=("$(printf '5h: %s%%' "$five_int")")
fi

# Join parts with separator
printf '%s' "${parts[0]}"
for part in "${parts[@]:1}"; do
  printf ' | %s' "$part"
done
printf '\n'
