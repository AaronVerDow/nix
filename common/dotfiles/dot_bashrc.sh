#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# Global bashrc workaround for NixOS
if [ -f /etc/bash.bashrc ]; then
    source /etc/bash.bashrc
else
    source ~/.bash.bashrc
fi

PATH="$HOME/bin:$PATH:$HOME/.local/bin"

instead_use() {
    echo "Use $1!" | lolcat -F 1.5
}

alias ip='ip -c'
alias grep='grep --color=auto'
alias halt='sudo /sbin/shutdown -h now'
alias ranger='ranger --choosedir=$HOME/.rangerdir; LASTDIR=`cat $HOME/.rangerdir`; cd "$LASTDIR"'
alias xclip='xclip -sel clip'
alias fd='fd --type f'
alias ncdu='instead_use gdu'
alias dmesg='sudo dmesg --color'
alias ccat='command cat'
alias unhardwrap='awk '\''BEGIN {RS="\n\n"; ORS="\n\n"} {gsub(/\n/, " "); print}'\'
which fdfind &> /dev/null && alias fd='fdfind --type f' 

# running vi against a directory will cd into it
vi() {
    if [[ -d ${!#} ]]; then
        instead_use cd
        return 1
    fi

    command nvim "$@"
    local return_value=$?
    wcgraph 2> /dev/null
    return $return_value
}

cd() {
    builtin cd "$@" || return $?

    # Is this in a git repo?
    local git_root
    if git_root=$(git rev-parse --show-toplevel 2> /dev/null); then

        # Only track the name to avoid symlink issues
        local git_name
        git_name=$(basename "$git_root")

        # Only show for new repos
        if [ "${ONEFETCH_LAST_REPO:-}" != "$git_name" ]; then
            export ONEFETCH_LAST_REPO=$git_name

            local cache_dir cache
            cache_dir=~/.cache/onefetch 
            [ -d "$cache_dir" ] || mkdir -p $cache_dir
            cache="$cache_dir/$git_name"
        
            # Show cached output if available
            [ -f "$cache" ] && cat "$cache"

            # Update cache in background
            (onefetch > "$cache" 2>/dev/null &)
        fi

        # wordcount graph for writing
        wcgraph
    fi

    ls
}

alias status='git status'
alias push='git push'
alias pull='git pull'
commit() {
    git commit -m "$*"
}

diff() {
    if [ -z "$1" ]; then
        git diff --color | diff-so-fancy
    elif [ -z "$2" ]; then
        git diff "$1" --color | diff-so-fancy
    else
        command diff --color=auto "$@"
    fi
}

alias sqlcat='nvimpager -c -- -c "set syntax=sql"'
cat() {
    # Do nothing if piped
    if [[ ! -t 1 ]]; then
        command cat "$@"
        return $?
    fi

    # PDFs can only be opened one at a time
    if [ -z "$2" ] && echo "$1" | grep -qi '\.pdf$'; then
        if which fancy-cat 2> /dev/null; then
            # this must currently be manually built per system and linked into ~/.local/bin/
            fancy-cat "$1"
            return $?
        else
            nohup evince "$1" &> /dev/null &
            return 0
        fi
    fi

    # Define categories for items that can be opened in bulk
    images=0
    markdown=0

    for file in "$@"; do
        if echo "$file" | grep -Eiq '\.(png|jpg|svg)$'; then
            ((images++))
            continue
        fi

        if echo "$file" | grep -Eiq '\.(md|rmd)$'; then
            ((markdown++))
            continue
        fi
        
        command cat "$@"
        return $?
    done

    total=$((images+markdown))

    if [ $images -gt 0 ] && [ $images -eq $total ]; then
        kitten icat "$@"
        return $?
    fi

    if [ $markdown -gt 0 ] && [ $markdown -eq $total ]; then
        mdcat "$@"
        return $?
    fi
}

# Forgot what this does, should probably replace less anyways
export LESS='-R --use-color -Dd+r$Du+b'
export LESS_TERMCAP_mb=$'\E[01;31m' \
LESS_TERMCAP_md=$'\E[01;38;5;74m' \
LESS_TERMCAP_me=$'\E[0m' \
LESS_TERMCAP_se=$'\E[0m' \
LESS_TERMCAP_so=$'\E[38;5;246m' \
LESS_TERMCAP_ue=$'\E[0m' \
LESS_TERMCAP_us=$'\E[04;38;5;146m'


# Organizing notes
export NOTES_DIRECTORY=~/notes

n() {
    if [ -z "$1" ]; then
        nls "$@"
        return
    fi

    local file
    file="$NOTES_DIRECTORY/$*"

    if [ -e "$file" ]; then
        cat "$file"
    else
        touch "$file"
    fi
}

ni() {
    if [ -z "$1" ]; then
        nls "$@"
        return
    fi
    $EDITOR "$NOTES_DIRECTORY/$*"
}

nls() {
    ls -ctr "$NOTES_DIRECTORY" | grep "$*"
}

_notes_autocomplete() {
    local cur="${COMP_WORDS[COMP_CWORD]}"

    local files
    files=$(find "$NOTES_DIRECTORY" -mindepth 1 -maxdepth 1 -type f -exec basename {} \; | while IFS= read -r line; do printf '%q\n' "$line"; done)

    mapfile -t COMPREPLY < <( compgen -W "$files" -- "$cur" )
}

complete -F _notes_autocomplete n
complete -F _notes_autocomplete ni
complete -F _notes_autocomplete nls

# journalctl tab completion for services
_journalctl_completion() {
    local cur="${COMP_WORDS[COMP_CWORD]}"
    local prev="${COMP_WORDS[COMP_CWORD-1]}"
    
    # Complete service names after -u flag
    if [[ "$prev" == "-u" || "$prev" == "--unit" ]]; then
        local services
        services=$(systemctl list-units --type=service --all --no-legend --no-pager --plain 2>/dev/null | awk '{print $1}')
        mapfile -t COMPREPLY < <( compgen -W "$services" -- "$cur" )
        return 0
    fi
    
    # Complete common journalctl flags
    local flags="-u --unit -f --follow -n --lines -p --priority -S --since -U --until -k --dmesg -b --boot -r --reverse --no-pager -o --output"
    mapfile -t COMPREPLY < <( compgen -W "$flags" -- "$cur" )
}

complete -F _journalctl_completion journalctl

# Temporary downloads directory
mkdir -p /tmp/averdow/.downloads &> /dev/null
[ -L "$HOME/tmp" ] || ln -s /tmp/averdow $HOME/tmp
[ -e "$HOME/Downloads" ] || ln -s $HOME/tmp/.downloads $HOME/Downloads # Downloads must be manually removed to get setup

# Keep more history
HISTFILESIZE=1000000
HISTSIZE=1000000
export HISTTIMEFORMAT=""
PROMPT_COMMAND="${PROMPT_COMMAND:+$PROMPT_COMMAND ; }"'history 1 >> ~/.eternal'
hist(){
	echo "$@" | grep -q . && history | grep "$@" || history
}

alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
alias ......='cd ../../../../..'
alias .......='cd ../../../../../..'
alias ........='cd ../../../../../../..'
alias .........='cd ../../../../../../../..'

alias ,,='echo "$OLDPWD" | grep -q "^$PWD/" && cd "$( echo "$OLDPWD" | sed "s#^$PWD##" | cut -d '/' -f -2 | sed 's#^/##' )"'
alias ,,,='echo "$OLDPWD" | grep -q "^$PWD/" && cd "$( echo "$OLDPWD" | sed "s#^$PWD##" | cut -d '/' -f -3 | sed 's#^/##' )"'
alias ,,,,='echo "$OLDPWD" | grep -q "^$PWD/" && cd "$( echo "$OLDPWD" | sed "s#^$PWD##" | cut -d '/' -f -4 | sed 's#^/##' )"'
alias ,,,,,='echo "$OLDPWD" | grep -q "^$PWD/" && cd "$( echo "$OLDPWD" | sed "s#^$PWD##" | cut -d '/' -f -5 | sed 's#^/##' )"'
alias ,,,,,,='echo "$OLDPWD" | grep -q "^$PWD/" && cd "$( echo "$OLDPWD" | sed "s#^$PWD##" | cut -d '/' -f -6 | sed 's#^/##' )"'
alias ,,,,,,,='echo "$OLDPWD" | grep -q "^$PWD/" && cd "$( echo "$OLDPWD" | sed "s#^$PWD##" | cut -d '/' -f -7 | sed 's#^/##' )"'
alias ,,,,,,,,='echo "$OLDPWD" | grep -q "^$PWD/" && cd "$( echo "$OLDPWD" | sed "s#^$PWD##" | cut -d '/' -f -8 | sed 's#^/##' )"'
alias ,,,,,,,,,='echo "$OLDPWD" | grep -q "^$PWD/" && cd "$( echo "$OLDPWD" | sed "s#^$PWD##" | cut -d '/' -f -9 | sed 's#^/##' )"'
alias ,,,,,,,,,,='echo "$OLDPWD" | grep -q "^$PWD/" && cd "$( echo "$OLDPWD" | sed "s#^$PWD##" | cut -d '/' -f -10 | sed 's#^/##' )"'

if [ -n "$PS1" ] && [ -z "$AIDER_CHECK_UPDATE" ]; then
    neofetch --config ~/.config/neofetch/config
fi

# BEGIN_KITTY_SHELL_INTEGRATION
if test -n "$KITTY_INSTALLATION_DIR" -a -e "$KITTY_INSTALLATION_DIR/shell-integration/bash/kitty.bash"; then source "$KITTY_INSTALLATION_DIR/shell-integration/bash/kitty.bash"; fi
# END_KITTY_SHELL_INTEGRATION

eval "$(direnv hook bash)"

[ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"

if [ -d "$HOME/.nvm" ]; then
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
fi

[ -d "$HOME/.rbenv/bin" ] && export PATH="$HOME/.rbenv/bin:$PATH"
which rbenv &> /dev/null && eval "$(rbenv init -)" || true

true
