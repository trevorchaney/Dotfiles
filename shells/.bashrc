#
# .bashrc
#

# Source global definitions if it exists.
[ -f /etc/bashrc ] && . /etc/bashrc

HISTFILE=~/.bash_history

# Sets Ctrl-s incremental search.
stty -ixon

# FZF settings, sourec if found
[ -f /usr/share/fzf/key-bindings.bash ] && source /usr/share/fzf/key-bindings.bash
[ -f /usr/share/fzf/completion.bash ] && source /usr/share/fzf/completion.bash

[ -r /usr/share/bash-completion/bash_completion ] && . /usr/share/bash-completion/bash_completion

# Initialize dircolors for ls colors
if type -P dircolors >/dev/null ; then
    if [[ -f ~/.dircolors ]] ; then
        eval $(dircolors -b ~/.dircolors)
    elif [[ -f /etc/DIR_COLORS ]] ; then
        eval $(dircolors -b /etc/DIR_COLORS)
    fi
fi


complete -cf sudo

# Bash won't get SIGWINCH if another process is in the foreground.
# Enable checkwinsize so that bash will check the terminal size when
# it regains control.  #65623
# http://cnswww.cns.cwru.edu/~chet/bash/FAQ (E11)
shopt -s checkwinsize

shopt -s expand_aliases

# export QT_SELECT=4

# Enable history appending instead of overwriting.  #139609
shopt -s histappend

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
shopt -s globstar

# Enables extended globing in shell options.(see: man extglob)
shopt -s extglob

# Enables globing of files that start with a dot (.)
shopt -s dotglob

# Enable spell checking.
shopt -s cdspell
# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

# Enable jump command for directory jumping
command -v jump >/dev/null 2>&1 && eval "$(jump shell bash)"

# Starship prompt
command -v starship >/dev/null 2>&1 && eval "$(starship init bash)"

# mise: full per-directory tool version activation (reads .mise.toml/.tool-versions)
command -v mise >/dev/null 2>&1 && eval "$(mise activate bash)"

# zoxide: adds z/zi fuzzy directory jumping, doesn't touch cd
command -v zoxide >/dev/null 2>&1 && eval "$(zoxide init bash)"

# Include common shell settings for bash and zsh if it exists. Sourced after
# jump/starship/mise/zoxide above: mise and zoxide both define their own cd()
# on activation, so ours needs to load last to be the one that's actually
# left standing (last function definition wins, no source-order-independent
# override mechanism exists for plain functions like there is for aliases).
[ -f ~/.shell_commons ] && . ~/.shell_commons

# Omarchy theming
export OMARCHY_PATH="/usr/share/omarchy"
export PATH="$OMARCHY_PATH/bin:$PATH"
export PATH="$HOME/.local/share/gem/ruby/3.4.0/bin:$PATH"

# User bin — overrides omarchy commands when needed
[ -d "$HOME/bin" ] && export PATH="$HOME/bin:$PATH"

. "$HOME/.local/share/../bin/env"
