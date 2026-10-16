Code Navigation: Prefer LSP tools over grep or reading entire files. Use workspaceSymbol for finding definitions, findReferences for usages, and hover for type info. Only fall back to grep for searching text, comments, or string values.

Git — integrating a branch: always rebase and merge. Never create a merge commit (no `git merge --no-ff`); integrate with a fast-forward after rebasing the branch onto its target. Where the situation calls for collapsing many small commits into one logical change, squash and merge instead — still with no merge commit. If a merge commit has already been pushed, redo the history and force-push with `--force-with-lease`.

Git — work in progress: for any task, work on a work-in-progress branch. Before starting, check whether you are already on a WIP branch with that task in progress — if so, keep using it, never open a second branch for the same work. Only create a new branch when the task is genuinely new. If it is at all unclear which applies (the current branch is a WIP branch but for different work, its scope has drifted, or you cannot tell whether the task is a continuation), ask the human to confirm the branch before starting, rather than guessing.

Commit and push after each iteration, not just at the end, so every iteration is recoverable from the remote. Once the task is done or reaches a milestone, squash that iteration's commits into one logical commit before moving forward (squash only — never a merge commit, per the rule above).

Every WIP branch name must include its creation date in human-readable form — the month as a word, never an all-numeric date: `qa/reverse-logistics-xstate-2026-sep-15`, not `qa/reverse-logistics-xstate-20260915`. The name must be unique and must not collide with a past or parallel branch, even for a task similar to one done before; the date plus the specific sub-scope is what keeps it unique.

Model routing for subagents (standing instruction; this counts as the user asking for subagents): the goal is the fewest total tokens to a correct result, not the cheapest price per token. A cheap model that needs a second round costs more than the right model once.
- **Ceiling = the session's current model.** Pick only from models at or below it (on Opus: haiku / sonnet / opus; on Sonnet: haiku / sonnet). Never pick a higher one (e.g. Fable) on your own. If the task needs more, stop and ask the user to switch models themselves.
- **Session model (orchestrator):** understanding the task and root cause, the plan and how it splits, cross-repo / contract / schema decisions, money and data-migration logic, reviewing every subagent diff, final verification.
- **sonnet:** a planned change in known files from a written spec; writing test/E2E checks; UI from an approved wireframe; build-and-fix loops.
- **haiku:** mechanical work with a check that proves it: running suites and reporting pass/fail, locating code, log triage, DB checks, spec-driven instrumentation passes.
- Every delegated subtask comes with a runnable pass/fail check. The result is verified, never trusted.
- A failure escalates one model up; never retry on the same model. After two failures at the ceiling, stop and ask the user.
- Don't delegate when the brief costs more than the work: a subagent starts cold, so if the brief would run over about 20 lines, or the change is a few lines in files already read, do it yourself.
- Never delegate releases, tags, pushes to shared branches, prod/master actions, or lockfile edits.

Delegation split, made visible: for multi-phase work, write the split (task → model → pass/fail check) into the plan or the first reply before starting, so the human can hold you to it. Anything with a written spec and a runnable check goes to a subagent per the routing above; you review the result.

Claims about existing code: saying "X already handles this / needs no change" requires having read X (file:line and the exact field or branch). Without that it is an assumption and must be labelled as one.

Context hygiene: never paste raw logs, whole pages or whole files into context. Filter first (grep for the error or field, `head`, the needed line range), check computed values instead of taking screenshots when a value answers the question, and send verbose exploration (log triage, UI selector discovery, suite runs) to subagents so only their conclusions come back.

Milestone checkpoints: at the end of each major step (plan approved, design locked, a slice built, verified, released), write the state to the task's plan file (build log: date, repo, commit/tag, status, what is next) and to memory, before moving on. The plan file, not the conversation, is the source of truth, so a compaction or `/clear` loses nothing that matters.

Plugins on demand: `vercel`, `context7`, `chrome-devtools-mcp` and `mongodb` (all `@claude-plugins-official`) are installed but disabled, to keep every session's prompt small. When a task needs one (Vercel deploy/config, library docs lookup, Chrome performance/Lighthouse/heap debugging that Playwright MCP can't do, Mongo index/schema/query-optimiser work beyond `mongosh`), run `claude plugin enable <name>@claude-plugins-official`, ask the human to type `/reload-plugins`, then use it. Disable it again at the end of the task (`claude plugin disable ...`). Never enable one just in case.

Plugin skills vs these rules (these rules win):
- superpowers `finishing-a-development-branch`: never its plain `git merge`. Integrate per the Git rules above: rebase onto the target, then `git merge --ff-only` (or squash), and push with `--force-with-lease` only for your own WIP branch.
- superpowers `using-git-worktrees`: the branch name follows the dated WIP rule, and the base comes from the project's instructions (never just the current checkout). Prefer `EnterWorktree` / `--worktree`.
- Code review: use the built-in `/code-review`; the `code-review` plugin is disabled as a duplicate.

# Compact instructions

When compacting, keep: the task and its acceptance criteria; every decision and correction the human made (their words, with dates); repos, branches, commits, tags, versions and file paths touched; the current step, what is done and what is next; open questions and known risks or gaps; rules the human set during the session. Point to the plan file and memory entries that hold details rather than restating them.
Drop: raw tool output, logs, file contents, screenshots, exploration that led nowhere, errors that were fixed (keep only the lesson if it will matter again), and anything already recorded in the plan file or memory.

# Second brain

Shared memory for every project and machine lives in `~/second-brain` (auto-memory directory). Its rules:

@~/second-brain/AGENTS.md
