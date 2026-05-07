# template

Personal dotfiles + global git hooks. Single source of truth — `$HOME` symlinks
to files here, so editing locally is editing the repo.

## New-machine setup

```bash
git clone https://github.com/thekizoch/template.git ~/github/template
~/github/template/setup
```

`setup` symlinks `.bashrc`, `.zshrc`, `.zshenv`, and `.git-hooks/` into `$HOME`,
then sets `git config --global core.hooksPath ~/.git-hooks`. Idempotent — safe
to re-run. Refuses to clobber existing real files; if one's in the way, it
tells you exactly how to move it aside.

## What's in here

| Path | Purpose |
|------|---------|
| `.bashrc` | Linux-machine bash config |
| `.zshrc` | macOS zsh config (aliases, bun PATH, gitnexus wrapper, `bin/` PATH) |
| `.zshenv` | Login-shell env |
| `.git-hooks/` | Global git hooks. See `.git-hooks/README.md` for hook details |
| `bin/` | Agent-agnostic shell primitives. See `bin/README.md` |
| `setup` | Idempotent installer |

## `wt` (the agent-agnostic worktree primitive)

`bin/wt` wraps `git worktree add` so symlink mirroring (via the global
`post-checkout` hook) and per-repo harness setup (`<repo>/.harness/setup`,
typically a port allocator) fire deterministically. Skill prose telling an
agent to "also run the post-checkout hook" is a probabilistic trigger;
`wt new` is a deterministic one. Same primitive serves Claude, Codex,
Gemini, or a human shell.

```bash
wt new feat-x          # creates .worktrees/feat-x off origin/dev
wt rm feat-x           # destroys it (worktree + branch)
wt ls                  # lists active worktrees
wt path feat-x         # prints absolute path
wt reconcile --all     # idempotently re-applies symlinks + setup to every worktree
wt --help
```

Per-repo conventions (port allocator, env file, etc.) live in
`<repo>/.harness/`. `wt` itself is repo-agnostic.
