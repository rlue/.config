# shellcheck disable=SC2153,SC1090
# GUARD CLAUSE =================================================================
# Only run for interactive shells
[[ $- =~ i ]] || return

# STAGING ======================================================================

# INITIALIZATION ===============================================================
# Auto-launch tmux
if [ -z "$SSH_CONNECTION" ]; then
  if [ -z "$TMUX" ]; then
    if infocmp xterm-256color-italic >/dev/null 2>&1; then
      export TERM=xterm-256color-italic
    fi

    if type tmux >/dev/null 2>&1; then
      if tmux ls 2>/dev/null | grep -i work: >/dev/null 2>&1; then
        tmux attach -t "*[wW][oO][rR][kK]" # for compatibility with rlue/utils/timer
      else
        tmux new -As work
      fi
    fi
    # or else initialize tmux plugins (if possible)
  else
    if [ "$(uname)" = Linux ] || type greadlink >/dev/null 2>&1; then
      source "$HOME/.config/tmux/tmux-git/init.sh" >/dev/null 2>&1
    fi

    if hash timer >/dev/null 2>&1 &&
       ! pgrep -f $(hash -t timer) >/dev/null 2>&1 &&
       [ "$(tmux display-message -p '#S')" = "work" ]; then
      delay="$(echo "900 - (($(date +%S) + ($(date +%M) * 60)) % 900)" | bc)"
      timer -qd "$delay" -r -1 15 15 15 15 &
    fi
  fi
fi

# SHELL OPTIONS ================================================================
# enable ^o (operate-and-get-next)
tty -s && stty discard undef

# enable ^s (i-search, cf. ^r)
# (see http://blog.bigsmoke.us/2013/08/05/readline-shortcuts-ctrl-s-and-xoff)
tty -s && stty -ixon

# .bash_history --------------------------------------------------------------
# don't put duplicate lines or lines starting with space in the history.
export HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
export HISTSIZE=1000
export HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# PER-PLATFORM CONFIGURATION ===================================================
# Linux ------------------------------------------------------------------------
if [ "$(uname)" = Linux ]; then
  # Debian ---------------------------------------------------------------------
  if [ -r /etc/debian_version ]; then
    # make less more friendly for non-text input files, see lesspipe(1)
    [ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"
    
    # Power Management ---------------------------------------------------------
    if type systemctl >/dev/null 2>&1; then
      if [ -z "$(type -t halt)" ];   then alias halt="systemctl poweroff";  fi
      if [ -z "$(type -t susp)" ];   then alias susp="systemctl suspend";   fi
      if [ -z "$(type -t hbnt)" ];   then alias hbnt="systemctl hibernate"; fi
      if [ -z "$(type -t reboot)" ]; then alias reboot="systemctl reboot";  fi
    fi

    # Colors -------------------------------------------------------------------
    export PS1="\[\033[38;5;187m\]\u@\h\[\033[m\]\[\033[38;5;174m\]:\w \$ \[\033[m\]"
    # colored GCC warnings and errors
    export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

    if [ -x /usr/bin/dircolors ]; then
      eval "$(dircolors -b)"
    fi

    for cmd in ls {,v}dir {,f,e}grep; do
      alias "$cmd=$cmd --color=auto"
    done
  fi

# Mac OS -----------------------------------------------------------------------
elif [ "$(uname)" = Darwin ]; then
  # Provides programmable tab-completion for, e.g., git branch names.
  # Requires `brew install bash-completion`,
  source "$(brew --prefix)/etc/bash_completion" >/dev/null 2>&1
fi

# APPLICATION SETUP ============================================================
# fzf --------------------------------------------------------------------------
# Auto-completion & key bindings
source "/usr/share/bash-completion/completions/fzf" >/dev/null 2>&1
source "/usr/share/doc/fzf/examples/key-bindings.bash" >/dev/null 2>&1

# broot ------------------------------------------------------------------------
source "$HOME/.config/broot/launcher/bash/br" >/dev/null 2>&1

# direnv -----------------------------------------------------------------------
if hash direnv >/dev/null 2>&1; then
  eval "$(direnv hook bash)"
fi

# <C-y> (mutt, newsbeuter) -----------------------------------------------------
# Scroll up in interactive programs (instead of sending DSUSP)
# shellcheck disable=SC2154
if stty -a | grep dsusp >/dev/null 2>&1; then
  function no_dsusp() {
    term_settings=$(stty -g)                      # Capture old termio params
    target_bin=$(type -P $1)                      # Capture target program
    shift                                         # Remove from pos. parameters
    stty dsusp undef                              # Disable DSUSP
    trap 'rc=$?; stty '"$term_settings"'; exit $rc' 0 1 2 3 15
                                                  # Restore termios on interrupt
    $target_bin "$@"                              # Run target program
    stty $term_settings                           # Restore termios on exit
  }

  hash newsboat >/dev/null 2>&1 && alias newsboat="no_dsusp $(type -P newsboat)"
fi

mutt="$(type -P mutt || type -P neomutt)"

if [ -n "$mutt" ]; then
  function mutt() {
    [ "$(type -t no_dsusp)" = "function" ] && no_dsusp "$mutt" "$@" || "$mutt" "$@"
    ssh -f ryanlue.com 'export GNUPGHOME="$HOME/.config/gnupg"; export PASSWORD_STORE_DIR="$HOME/.config/pass"; sleep 60; pgrep mbsync >/dev/null || mbsync --all --verbose --config "$HOME/.config/mbsync/config" >log/mbsync.log 2>&1'
  }
fi

# $ brew find ------------------------------------------------------------------
# Interactively search-and-install formulae
if hash brew >/dev/null 2>&1; then
  function brew() {
    brew=$(type -P brew)
    if hash rg >/dev/null 2>&1; then
      grepprg='rg'
    else
      grepprg='grep'
    fi

    case "$1" in
      find)
        fzf_opts=("--multi" "--query=$2" "--preview=$brew info {1}" "--preview-window=$([ $(tput lines) -gt $(tput cols) ] && printf right || printf up)")
        choice=$($brew search | sed -f <($brew list | sed 's/.*/s\/^&$\/\& (installed)\//') | fzf "${fzf_opts[@]}" )

        if [ $? -eq 0 ] && [ -n "$choice" ]; then
          already_installed=$(echo "$choice" | $grepprg -F -x -f <($brew list) -)
          if [ $? -eq 0 ] && [ -n "$already_installed" ]; then
            echo "The following formulae are already installed:"
            echo $already_installed
          fi

          to_install=$(echo "$choice" | $grepprg -F -x -v -f <($brew list) -)
          if [ $? -eq 0 ] && [ -n "$to_install" ]; then
            $brew install $to_install
          else
            echo "No new formulae to install."
          fi
        fi
        ;;
      *) $brew "$@" ;;
    esac
  }
fi

# ALIASES ======================================================================
# better UNIX tools ------------------------------------------------------------
if hash bat >/dev/null 2>&1; then
  alias cat='bat'
fi

if hash fd >/dev/null 2>&1; then
  alias find='fd'
fi

if hash rg >/dev/null 2>&1; then
  alias grep='rg'
fi

if hash exa >/dev/null 2>&1; then
  alias ls='exa'
fi

if hash prettyping >/dev/null 2>&1; then
  alias ping='prettyping --nolegend'
fi

if hash htop >/dev/null 2>&1; then
  alias top='htop'
fi

if hash ncdu >/dev/null 2>&1; then
  alias ncdu='ncdu --color dark -rr -x --exclude .git --exclude node_modules'
fi

# cd ---------------------------------------------------------------------------
# to root directory of current git repo
if hash git >/dev/null 2>&1; then
  alias cdr='git status >/dev/null 2>&1 && cd $(git rev-parse --show-toplevel) || cd'
fi

# cd with fzf
# shellcheck disable=SC2139
if hash fd >/dev/null 2>&1 && hash fzf >/dev/null 2>&1; then
  alias fzd='cd ./$(fd --type d | fzf-tmux +m --preview="ls {}")'
fi

# Bundler ----------------------------------------------------------------------
alias b='bundle exec'
alias bj='bundle exec jekyll'

function bundle() {
  bundle="$(type -P bundle)"
  project_root="$(git rev-parse --show-toplevel 2>/dev/null)/"
  local_gemfile="$(realpath "$BUNDLE_GEMFILE" 2>/dev/null)" # NOTE: not OSX-portable

  if [ -r "$local_gemfile" ] && [ -r "${project_root}Gemfile" ] &&
     ! [[ "$local_gemfile" =~ $(printf %s '\bGemfile$') ]] &&
     [[ "$1" =~ ^(|install|update)$ ]]; then
    BUNDLE_GEMFILE="${project_root}Gemfile" "$bundle" "$@"
    cp "${project_root}Gemfile.lock" "$local_gemfile.lock"
  fi

  "$bundle" "$@"
}

# xdg-open ---------------------------------------------------------------------
if hash xdg-open >/dev/null 2>&1; then
  alias open='xdg-open'
fi

# waitfor ----------------------------------------------------------------------
# via http://blog.joncairns.com/2013/03/wait-for-a-unix-process-to-finish/
function waitfor() {
  if [ -z "$1" ]; then
    echo "waitfor: no process name given" >&2
    return 2
  elif [[ "$1" =~ [^[:digit:]] ]]; then
    name="$1"
    pid=$(pgrep -f "$1")
  else
    pid="$1"
    name="$(ps -p $pid -o comm=)"
  fi

  if [ $? -ne 0 ] || [[ $pid == *$'\n'* ]]; then
    if [[ $pid == *$'\n'* ]]; then
      echo "waitfor: found multiple processes named \"$name\"" >&2
    elif [ -z $pid ]; then
      echo "waitfor: failed to find process \"$name\"" >&2
    else
      echo "waitfor: failed to find process $pid" >&2
    fi

    return 1
  else
    echo "waiting for $name to finish ($pid)"
    while ps -p $pid > /dev/null; do sleep 1; done
  fi
}

if hash timer >/dev/null 2>&1; then
  function lmk() {
    waitfor "$1" && timer 0 >/dev/null
  }
fi
