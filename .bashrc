# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)

# ==============================================================================
# 1. SHELL BEHAVIOR & HISTORY
# ==============================================================================

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# Don't put duplicate lines or lines starting with space in the history.
HISTCONTROL=ignoreboth
# Append to the history file, don't overwrite it
shopt -s histappend

# Increased history limits
export HISTSIZE=10000
export HISTFILESIZE=10000

# Check the window size after each command and update LINES and COLUMNS.
shopt -s checkwinsize

# ==============================================================================
# 2. PROMPT & VISUALS
# ==============================================================================

# Make less more friendly for non-text input files
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# Set variable identifying the chroot you work in
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# Set a fancy prompt (color support)
case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
esac

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
        color_prompt=yes
    else
        color_prompt=
    fi
fi

if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

# Enable color support of ls and add standard aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# ==============================================================================
# 3. ALIASES & FUNCTIONS
# ==============================================================================

# Standard LS aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# Long running command alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# --- Custom Workflow Aliases ---
alias c="clear"
alias p='pytest'
alias r="uv run ruff check --fix ."
alias re='repomix'
alias gs='git status'
alias gw='git worktree list'
alias t='tree --gitignore'
alias d='deactivate'

# Git fast commit & push
x() { 
    git add . && git commit -m "${1:-x}" && git push
}

# Grep shell history
g() {
    if [ $# -eq 1 ]; then
        history | grep "$1"
    else
        history | grep "$*"
    fi
}

# Kill process by port
k() { 
    lsof -ti:"$1" | xargs kill -9 
}

# Recursively search upwards for Python .venv to activate
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

# ==============================================================================
# 4. EXTERNAL TOOLS & PATHS
# ==============================================================================

# Local user binaries
[ -f "$HOME/.local/bin/env" ] && . "$HOME/.local/bin/env"

# Enable programmable completion features
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

# NVM (Node Version Manager)
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# Direnv
if command -v direnv &> /dev/null; then
    eval "$(direnv hook bash)"
fi

# Google Cloud SDK 
# (Attempt standard Linux install paths instead of Mac's brew path)
if [ -f "$HOME/google-cloud-sdk/path.bash.inc" ]; then
    source "$HOME/google-cloud-sdk/path.bash.inc"
    source "$HOME/google-cloud-sdk/completion.bash.inc"
elif [ -f "/usr/lib/google-cloud-sdk/path.bash.inc" ]; then
    source "/usr/lib/google-cloud-sdk/path.bash.inc"
    source "/usr/lib/google-cloud-sdk/completion.bash.inc"
fi

# Mac Homebrew libpq path removed. On Linux, PostgreSQL client tools are 
# typically in standard paths (/usr/bin) via `sudo apt install postgresql-client`.
# export PATH="/opt/homebrew/opt/libpq/bin:$PATH"

# Source separated bash aliases if they exist
if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi
