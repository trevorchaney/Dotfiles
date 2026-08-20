#
# .zshrc
#

## Include common shell settings for bash and zsh.
[ -f ~/.shell_commons ] && . ~/.shell_commons

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# If not running interactively, don't do anything.
[[ $- != *i* ]] && return

HISTFILE=~/.zsh_history

# FZF settings, source if found
[ -f /usr/share/fzf/key-bindings.zsh ] && source /usr/share/fzf/key-bindings.zsh
[ -f /usr/share/fzf/completion.zsh ] && source /usr/share/fzf/completion.zsh
export FZF_COMPLETION_TRIGGER="<>"

# The following lines were added by compinstall
zstyle :compinstall filename '/home/tlc/.zshrc'

autoload -Uz compinit colors zcalc
compinit
colors

# End of lines added by compinstall

## Options section
setopt appendhistory                # Immediately append history instead of overwriting
setopt autocd                       # If only directory path is entered, cd there.
setopt beep                         # Beep on error.
setopt nocaseglob                   # Case insensitive globbing
setopt nocheckjobs                  # Don't warn about running processes when exiting
setopt correct                      # Auto correct mistakes
setopt extendedglob                 # Extended globbing. Allows using regular expressions with *
setopt histexpiredupsfirst          # This option will cause the oldest event that has a duplicate to be lost before losing a unique event
setopt histignorealldups            # The older instance of a command is removed from history (even if it is not the previous event).
setopt histignoredups               # Do not enter command lines into the history list if they are duplicates of the previous event.
setopt histsavenodups               # When writing out the history file, older commands that duplicate newer ones are omitted.
setopt incappendhistory             # Works like APPEND_HISTORY except that new history lines are added to the $HISTFILE incrementally
setopt nomatch                      # If a pattern for filename generation has no matches, print an error.
setopt notify                       # Report the status of background jobs immediately.
setopt numericglobsort              # Sort filenames numerically when it makes sense
setopt prompt_subst                 # Enable substitution for prompt
setopt rcexpandparam                # Array expension with parameters
setopt sharehistory                 # Imports new commands from the history and causes typed commands to be appended to history.

zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'       # Case insensitive tab completion
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"         # Colored completion (different colors for dirs/files/etc)
zstyle ':completion:*' rehash true                              # automatically find new executables in path 

# Speed up completions
zstyle ':completion:*' accept-exact '*(N)'
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path ~/.zsh/cache
# ---new---
# zstyle ':completion:*' add-space true
# zstyle ':completion:*' completer _list _oldlist _expand _complete _ignored _match _correct _approximate _prefix
# zstyle ':completion:*' max-errors 3
# zstyle ':completion:*' old-list always
# zstyle ':completion:*' old-menu false
# zstyle ':completion:*' prompt '>>>'
# zstyle ':completion:*' word true

## Plugins section: Enable fish style features
# Use syntax highlighting
[ -f /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ] \
    && source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
# Use history substring search
[ -f /usr/share/zsh/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh ] \
    && source /usr/share/zsh/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh
# bind UP and DOWN arrow keys to history substring search
zmodload zsh/terminfo
bindkey "$terminfo[kcuu1]" history-substring-search-up
bindkey "$terminfo[kcud1]" history-substring-search-down
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down

# Offer to install missing package if command is not found
if [[ -r /usr/share/zsh/functions/command-not-found.zsh ]]; then
    source /usr/share/zsh/functions/command-not-found.zsh
    export PKGFILE_PROMPT_INSTALL_MISSING=1
fi

# Use autosuggestion, if it exists
[ -f /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh ] \
    && source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=8'

# source ~/.zsh_plugins.sh

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
# [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

if [ -e /home/tlc/.nix-profile/etc/profile.d/nix.sh ]; then . /home/tlc/.nix-profile/etc/profile.d/nix.sh; fi # added by Nix installer

# Enable jump command for directory jumping
command -v jump >/dev/null 2>&1 && eval "$(jump shell zsh)"

# Starship prompt
command -v starship >/dev/null 2>&1 && eval "$(starship init zsh)"

. "$HOME/.local/share/../bin/env"
