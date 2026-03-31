export HISTSIZE=10000
export SAVEHIST=10000
setopt APPEND_HISTORY

alias p='pytest'

unalias a 2>/dev/null
a() {
  local venv_path
  venv_path=$(pwd)
  while [[ "$venv_path" != "" && ! -f "$venv_path/.venv/bin/activate" ]]; do
    venv_path=${venv_path%/*}
  done
  if [ -f "$venv_path/.venv/bin/activate" ]; then
    source "$venv_path/.venv/bin/activate"
    echo "Activated venv in $venv_path"
  else
    echo "source: no such file or directory: .venv/bin/activate"
    return 1
  fi
}
alias d='deactivate'
alias re='repomix'
alias gs='git status'
alias gw='git worktree list'

alias c="clear"
alias r="uv run ruff check --fix ."

# function to git fast
x() { git add . && git commit -m "${1:-x}" && git push; }

# Function to grep shell history
g() {
    if [ $# -eq 1 ]; then
        history 0 | grep "$1"
    else
        # Join all arguments with spaces for multi-word search
        history 0 | grep "$*"
    fi
}

. "$HOME/.local/bin/env"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
# Google Cloud SDK
source "$(brew --prefix)/share/google-cloud-sdk/path.zsh.inc"
source "$(brew --prefix)/share/google-cloud-sdk/completion.zsh.inc"
export PATH="/opt/homebrew/opt/libpq/bin:$PATH"

# Tree alias respecting gitignore
alias t='tree --gitignore'
k() { lsof -ti:$1 | xargs kill -9 }

# direnv hook
eval "$(direnv hook zsh)"
