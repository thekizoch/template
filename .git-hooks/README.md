# ~/.git-hooks/

Global git hooks installed via `core.hooksPath`. Sync this directory in your
dotfiles to carry the setup across machines.

## What's here

| File | Role |
|------|------|
| `post-checkout` | Mirrors `<main_repo>/.worktree-symlinks` into linked worktrees. Implementation file. |
| `_chain` | Generic pass-through helper — execs into the per-repo hook of the same name if it exists. |
| `pre-commit`, `post-commit`, `pre-push` | Symlinks to `_chain`. Pure pass-through so per-repo hooks (GitNexus reindex, project pre-commits) still fire under `core.hooksPath`. |

## New-machine setup

1. Clone your dotfiles. Symlink or copy this directory to `~/.git-hooks/`.
2. `git config --global core.hooksPath ~/.git-hooks`.
3. Done. Existing repos pick it up immediately.

## Adding worktree symlinks to a repo

Drop a file at `<repo>/.worktree-symlinks` listing paths to mirror from the
main repo into every linked worktree, one per line. Example:

```
clyzdale/node_modules
clyzdale/packages/ui/node_modules
```

The hook auto-no-ops in repos without this file.

## Why `post-checkout` is invoked explicitly by `/start-worktree`

Modern git (~2.43+) uses `git reset --hard` internally to populate a new
worktree, which does NOT fire `post-checkout`. The hook still fires for
branch-switch checkouts within an existing worktree, but for fresh worktrees
the trigger is explicit:

```bash
~/.git-hooks/post-checkout HEAD HEAD 1
```

`/start-worktree` Step 4 calls this from inside the new worktree. Other
worktree-creating skills (Codex, Gemini equivalents) need the same one-line
invocation.

## Adding a new hook type

If you start using a new git hook type (e.g., `commit-msg`) and want per-repo
hooks of that type to keep firing under `core.hooksPath`, add a symlink:

```bash
ln -s _chain ~/.git-hooks/commit-msg
```

Without the symlink, git silently skips per-repo hooks of that type.
