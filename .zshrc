alias a='source .venv/bin/activate'
alias d='deactivate'
alias re='repomix'
alias gs='git status'

alias c="clear"
alias r="uv run ruff check --fix ."

# function to git fast
x() { git add . && git commit -m "${1:-x}" && git push; }

# Function to grep shell history
g() {
    if [ $# -eq 1 ]; then
        history | grep "$1"
    else
        # Join all arguments with spaces for multi-word search
        history | grep "$*"
    fi
}
