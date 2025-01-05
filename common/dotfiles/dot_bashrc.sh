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

export NIX_SHELL_PRESERVE_PROMPT=1
export NIXPKGS_ALLOW_UNFREE=1
export EDITOR=nvim

alias ip='ip -c'
alias diff='diff --color=auto'
alias grep='grep --color=auto'
alias halt='sudo /sbin/shutdown -h now'
alias yolo='git push'
alias ranger='ranger --choosedir=$HOME/.rangerdir; LASTDIR=`cat $HOME/.rangerdir`; cd "$LASTDIR"'
alias xclip='xclip -sel clip'
alias fd='fd --type f'
which fdfind &> /dev/null && alias fd='fdfind --type f' 

# running vi against a directory will cd into it
vi() {
    if [[ -d ${!#} ]]; then
	echo "Use cd!" | lolcat -a -d 24
        cd "$@" || return $?
    fi

    command nvim "$@"
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
            onefetch
            export ONEFETCH_LAST_REPO=$git_name
        fi
    fi

    ls
}

alias sqlcat='nvimpager -c -- -c "set syntax=sql"'
cat() {
    # Do nothing if piped
    if [[ ! -t 1 ]]; then
        command cat "$@"
        return $?
    fi

    # Define categories
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
	cat "$NOTES_DIRECTORY/$*"
}

ni() {
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

eternal() {
    cat $HOME/.eternal | sed 's/^ *[0-9]* *//' | egrep -v '^(hist |eternal)' | egrep -a $@
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

if [ -n "$PS1" ]; then
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
