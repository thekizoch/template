# ~/.git-hooks/

Global git hooks installed via `core.hooksPath`. Sync this directory in your
dotfiles to carry the setup across machines.

## What's here

| File | Role |
|------|------|
| `post-checkout` | Mirrors `<main_repo>/.worktree-symlinks` into linked worktrees. Implementation file. |
| `_chain` | Generic pass-through helper — execs into the per-repo hook of the same name if it exists. |
| `pre-commit` | Real script: runs every executable in `checks/` against staged files, then chains to per-repo `.git/hooks/pre-commit`. |
| `post-commit`, `pre-push` | Symlinks to `_chain`. Pure pass-through so per-repo hooks (GitNexus reindex, project hooks) still fire under `core.hooksPath`. |
| `checks/` | Universal pre-commit checks. Drop in any executable script — it runs on every commit in every repo. |

## Universal pre-commit checks (`checks/`)

The `checks/` directory holds tool-agnostic checks that fire for every
commit, regardless of who staged the change (Claude, Codex, Gemini,
human). Each check is an executable script that:

- Receives the same args git passed to `pre-commit`
- Inspects the staged index itself (`git diff --cached`) or accepts file
  paths as arguments for direct invocation
- Returns 0 to pass, non-zero to block the commit

Currently shipped:

| Check | Enforces |
|-------|----------|
| `exec-plan-lint.sh` | Active execution plans (`docs/exec-plans/active/*.md`) declare `## Done means`, `## Out of scope`, and `## Verification mode` (one of: `browser`, `slack`, `backend-http`, `unit`, `none`). A plan without testable Done is a wish, not a contract. |

Each check is also usable from the CLI or per-tool agent hooks (Claude
Code `PostToolUse`, Codex/Gemini equivalents) for fast feedback during
authoring — the script is the primitive, the wiring is per-tool.

### Pre-commit framework conflict (`pre-commit install` overrides global hooks)

If a repo uses the [`pre-commit`](https://pre-commit.com) python framework,
`pre-commit install` sets a *local* `core.hooksPath = .git/hooks` that
overrides the global one. Symptom: universal checks silently stop firing
in that repo while the framework continues to run.

To restore the chain in a repo that uses the framework:

```bash
git -C <repo> config --local --unset core.hooksPath
```

After unsetting, the global `pre-commit` runs first (universal `checks/`),
then chains to the framework's installed hook at `.git/hooks/pre-commit`.
Both layers fire; neither loses functionality. Re-running
`pre-commit install` will re-set the local override — re-unset after.

## New-machine setup

1. Clone your dotfiles. Symlink or copy this directory to `~/.git-hooks/`.
2. `git config --global core.hooksPath ~/.git-hooks`.
3. Done. Existing repos pick it up immediately.

## Adding worktree symlinks to a repo

Drop a file at `<repo>/.harness/worktree-symlinks` listing paths to mirror
from the main repo into every linked worktree, one per line. Example:

```
clyzdale/node_modules
clyzdale/packages/ui/node_modules
clyzdale/credentials
```

`post-checkout` reads `<repo>/.harness/worktree-symlinks` first, then falls
back to `<repo>/.worktree-symlinks` (legacy location at the repo root). New
repos should write the manifest under `.harness/`; the root location is
kept for repos not yet migrated.

The hook auto-no-ops in repos without either file.

## Why `post-checkout` is invoked explicitly (and how `wt` handles it)

Modern git (~2.43+) uses `git reset --hard` internally to populate a new
worktree, which does NOT fire `post-checkout`. The hook still fires for
branch-switch checkouts within an existing worktree, but for fresh worktrees
the trigger is explicit:

```bash
~/.git-hooks/post-checkout HEAD HEAD 1
```

The agent-agnostic primitive `~/github/template/bin/wt` (see top-level
`README.md`) calls this for you on every `wt new <slug>`, so per-tool skills
(`/start-worktree` for Claude, equivalents for Codex / Gemini / Aider)
collapse to one-line wrappers around `wt`.

If you ever invoke `git worktree add` directly without going through `wt`,
remember to fire the hook from inside the new worktree, or symlinks won't
populate.

## Adding a new hook type

If you start using a new git hook type (e.g., `commit-msg`) and want per-repo
hooks of that type to keep firing under `core.hooksPath`, add a symlink:

```bash
ln -s _chain ~/.git-hooks/commit-msg
```

Without the symlink, git silently skips per-repo hooks of that type.
