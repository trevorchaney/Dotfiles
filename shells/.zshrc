#
# .zshrc
#

# If not running interactively, don't do anything.
[[ $- != *i* ]] && return

# Include common shell settings for bash and zsh if it exists.
[ -f $HOME/.shell_commons ] && . $HOME/.shell_commons

HISTFILE=~/.zsh_history

## Keybindings section
# Set vi keybindings for stream editing.
bindkey -v
bindkey -v '^?' backward-delete-char
bindkey -v "^[[A" history-search-backward
bindkey -v '^R' history-incremental-pattern-search-backward
bindkey -v '^S' history-incremental-pattern-search-forward

# Theming section
autoload -U compinit colors zcalc
compinit -d

# FZF settings.
source /usr/share/fzf/key-bindings.zsh
source /usr/share/fzf/completion.zsh
export FZF_COMPLETION_TRIGGER="<>"

# The following lines were added by compinstall
zstyle :compinstall filename '/home/tlc/.zshrc'

autoload -Uz compinit
compinit
# End of lines added by compinstall

## Options section
setopt appendhistory                # Immediately append history instead of overwriting
setopt autocd                       # If only directory path is entered, cd there.
setopt beep                         # Beep on error.
setopt nocaseglob                   # Case insensitive globbing
setopt nocheckjobs                  # Don't warn about running processes when exiting
setopt correct                      # Auto correct mistakes
setopt extendedglob                 # Extended globbing. Allows using regular expressions with *
setopt histignorealldups            # If a new command is a duplicate, remove the older one
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


## Plugins section: Enable fish style features
# Use syntax highlighting
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
# Use history substring search
source /usr/share/zsh/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh
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

# Prompt (on left side) similar to default bash prompt, or redhat zsh prompt with colors
 #PROMPT="%(!.%{$fg[red]%}[%n@%m %1~]%{$reset_color%}# .%{$fg[green]%}[%n@%m %1~]%{$reset_color%}$ "
# Maia prompt
PROMPT="%B%{$fg[cyan]%}%(4~|%-1~/.../%2~|%~)%u%b >%{$fg[cyan]%}>%B%(?.%{$fg[cyan]%}.%{$fg[red]%})>%{$reset_color%}%b " # Print some system information when the shell is first started
# Print a greeting message when shell is started
echo $USER@$HOST  $(uname -srm) $(lsb_release -rcs)
## Prompt on right side:
#  - shows status of git when in git repository (code adapted from https://techanic.net/2012/12/30/my_git_prompt_for_zsh.html)
#  - shows exit status of previous command (if previous command finished with an error)
#  - is invisible, if neither is the case

# Modify the colors and symbols in these variables as desired.
GIT_PROMPT_SYMBOL="%{$fg[blue]%}±"                              # plus/minus     - clean repo
GIT_PROMPT_PREFIX="%{$fg[green]%}[%{$reset_color%}"
GIT_PROMPT_SUFFIX="%{$fg[green]%}]%{$reset_color%}"
GIT_PROMPT_AHEAD="%{$fg[red]%}ANUM%{$reset_color%}"             # A"NUM"         - ahead by "NUM" commits
GIT_PROMPT_BEHIND="%{$fg[cyan]%}BNUM%{$reset_color%}"           # B"NUM"         - behind by "NUM" commits
GIT_PROMPT_MERGING="%{$fg_bold[magenta]%}⚡︎%{$reset_color%}"     # lightning bolt - merge conflict
GIT_PROMPT_UNTRACKED="%{$fg_bold[red]%}●%{$reset_color%}"       # red circle     - untracked files
GIT_PROMPT_MODIFIED="%{$fg_bold[yellow]%}●%{$reset_color%}"     # yellow circle  - tracked files modified
GIT_PROMPT_STAGED="%{$fg_bold[green]%}●%{$reset_color%}"        # green circle   - staged changes present = ready for "git push"

parse_git_branch() {
  # Show Git branch/tag, or name-rev if on detached head
  ( git symbolic-ref -q HEAD || git name-rev --name-only --no-undefined --always HEAD ) 2> /dev/null
}

parse_git_state() {
  # Show different symbols as appropriate for various Git repository states
  # Compose this value via multiple conditional appends.
  local GIT_STATE=""
  local NUM_AHEAD="$(git log --oneline @{u}.. 2> /dev/null | wc -l | tr -d ' ')"
  if [ "$NUM_AHEAD" -gt 0 ]; then
    GIT_STATE=$GIT_STATE${GIT_PROMPT_AHEAD//NUM/$NUM_AHEAD}
  fi
  local NUM_BEHIND="$(git log --oneline ..@{u} 2> /dev/null | wc -l | tr -d ' ')"
  if [ "$NUM_BEHIND" -gt 0 ]; then
    GIT_STATE=$GIT_STATE${GIT_PROMPT_BEHIND//NUM/$NUM_BEHIND}
  fi
  local GIT_DIR="$(git rev-parse --git-dir 2> /dev/null)"
  if [ -n $GIT_DIR ] && test -r $GIT_DIR/MERGE_HEAD; then
    GIT_STATE=$GIT_STATE$GIT_PROMPT_MERGING
  fi
  if [[ -n $(git ls-files --other --exclude-standard 2> /dev/null) ]]; then
    GIT_STATE=$GIT_STATE$GIT_PROMPT_UNTRACKED
  fi
  if ! git diff --quiet 2> /dev/null; then
    GIT_STATE=$GIT_STATE$GIT_PROMPT_MODIFIED
  fi
  if ! git diff --cached --quiet 2> /dev/null; then
    GIT_STATE=$GIT_STATE$GIT_PROMPT_STAGED
  fi
  if [[ -n $GIT_STATE ]]; then
    echo "$GIT_PROMPT_PREFIX$GIT_STATE$GIT_PROMPT_SUFFIX"
  fi
}

git_prompt_string() {
  local git_where="$(parse_git_branch)"

  # If inside a Git repository, print its branch and state
  [ -n "$git_where" ] && echo "$GIT_PROMPT_SYMBOL$(parse_git_state)$GIT_PROMPT_PREFIX%{$fg[yellow]%}${git_where#(refs/heads/|tags/)}$GIT_PROMPT_SUFFIX"

  # If not inside the Git repo, print exit codes of last command (only if it failed)
  [ ! -n "$git_where" ] && echo "%{$fg[red]%} %(?..[%?])"
}

# Right prompt with exit status of previous command if not successful
 #RPROMPT="%{$fg[red]%} %(?..[%?])"
# Right prompt with exit status of previous command marked with ✓ or ✗
 #RPROMPT="%(?.%{$fg[green]%}✓ %{$reset_color%}.%{$fg[red]%}✗ %{$reset_color%})"

# Apply different settings for different terminals
case $(basename "$(cat "/proc/$PPID/comm")") in
    login)
        RPROMPT="%{$fg[red]%} %(?..[%?])" 
        alias x='startx ~/.xinitrc'      # Type name of desired desktop after x, xinitrc is configured for it
        ;;
    'tmux: server')
        RPROMPT='$(git_prompt_string)'
        ## Base16 Shell color themes.
        #possible themes: 3024, apathy, ashes, atelierdune, atelierforest, atelierhearth,
        #atelierseaside, bespin, brewer, chalk, codeschool, colors, default, eighties,
        #embers, flat, google, grayscale, greenscreen, harmonic16, isotope, londontube,
        #marrakesh, mocha, monokai, ocean, paraiso, pop (dark only), railscasts, shapesifter,
        #solarized, summerfruit, tomorrow, twilight
        #theme="eighties"
        #Possible variants: dark and light
        #shade="dark"
        #BASE16_SHELL="/usr/share/zsh/scripts/base16-shell/base16-$theme.$shade.sh"
        #[[ -s $BASE16_SHELL ]] && source $BASE16_SHELL
        # Use autosuggestion
        source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
        ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20
        ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=8'
        ;;
    *)
        RPROMPT='$(git_prompt_string)'
        # Use autosuggestion
        source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
        ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20
        ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=8'
        ;;
esac

if [ -e /home/tlc/.nix-profile/etc/profile.d/nix.sh ]; then . /home/tlc/.nix-profile/etc/profile.d/nix.sh; fi # added by Nix installer

# Enable jump command for directory jumping
eval "$(jump shell zsh)"
