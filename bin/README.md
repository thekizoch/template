# ~/github/template/bin/

Agent-agnostic shell primitives. Sourced into `$PATH` by `.zshrc`:

```bash
export PATH="$HOME/github/template/bin:$PATH"
```

(Hardcoded path — if you cloned the template elsewhere, edit `.zshrc`.)

## What's here

| Binary | Role |
|--------|------|
| `wt` | Worktree provisioner. Wraps `git worktree add`, fires the global `post-checkout` symlink hook explicitly, then runs `<repo>/.harness/setup` if present. See top-level `README.md` for usage. |

## Why `bin/` instead of more skills

Skill prose ("…then run the post-checkout hook") is a probabilistic trigger.
A binary in `$PATH` is deterministic — it works the same whether invoked by
Claude, Codex, Gemini, or a human shell. Agent-specific skills become
one-line wrappers around these primitives instead of carrying setup logic.
