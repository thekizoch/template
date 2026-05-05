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
| `.zshrc` | macOS zsh config (aliases, bun PATH, gitnexus wrapper) |
| `.zshenv` | Login-shell env |
| `.git-hooks/` | Global git hooks. See `.git-hooks/README.md` for hook details |
| `setup` | Idempotent installer |
