# shellcheck disable=SC2153,SC1090
# GUARD CLAUSE =================================================================
# Only run for interactive shells
[[ $- =~ i ]] || return

# STAGING ======================================================================

# INITIALIZATION ===============================================================
# if [ "$(ps -o comm= $PPID)" = fbterm ]; then
#   export TERM=fbterm
#   source "$HOME/.config/fbterm/colors/hybrid" 2>/dev/null
# fi

if [ -z "$SSH_CONNECTION" ]; then
  # # if in virtual terminal, start fbterm (with 256 color support)
  # if type fbterm >/dev/null 2>&1 && [[ "$(tty)" =~ /dev/tty ]]; then
  #   if type fcitx >/dev/null 2>&1 && type fcitx-fbterm-helper >/dev/null 2>&1; then
  #     pgrep -x fcitx >/dev/null 2>&1 && fcitx-fbterm-helper || fcitx-fbterm-helper -l
  #   else
  #     fbterm
  #   fi
  # or if not in tmux, set TERM and start tmux (if possible)
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

    if hash timer >/dev/null 2>&1 && ! pgrep -f $(hash -t timer) >/dev/null 2>&1; then
      timer -qr -1 15 15 15 15 &
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
  # Provides programmable tab-completion for, e.g., git branch names.
  # May be redundant if already sourced in /etc/bash.bashrc (via /etc/profile).
  # if ! shopt -oq posix; then
  #   for f in /{usr/share/bash-completion,etc}/bash_completion; do
  #     if [ -r "$f" ]; then source "$f"; break; fi
  #   done
  # fi

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
# helper functions -------------------------------------------------------------
function pkgpath() {
  if type realpath >/dev/null 2>&1; then
    binpath="$(realpath "$(type -p $1)")"
  elif type perl >/dev/null 2>&1; then
    binpath="$(perl -MCwd -le 'print Cwd::abs_path(shift)' "$(type -p $1)")"
  fi

  echo "$(dirname "$(dirname $binpath)")"
}

# fzf --------------------------------------------------------------------------
# Auto-completion & key bindings
if type fzf >/dev/null 2>&1; then
  for f in "$(pkgpath fzf)/shell/"*.bash; do source "$f" >/dev/null 2>&1; done
fi

# chruby -----------------------------------------------------------------------
if type chruby-exec >/dev/null 2>&1; then
  # chruby.sh _must_ be sourced first
  source "$(pkgpath chruby-exec)/share/chruby/chruby.sh" >/dev/null 2>&1
  source "$(pkgpath chruby-exec)/share/chruby/auto.sh" >/dev/null 2>&1
fi

# direnv -----------------------------------------------------------------------
if hash direnv >/dev/null 2>&1; then
  eval "$(direnv hook bash)"
fi

# helper functions -------------------------------------------------------------
unset -f pkgpath

# <C-y> (mutt, newsbeuter) -----------------------------------------------------
# Scroll up in interactive programs (instead of sending DSUSP)
# shellcheck disable=SC2154
if stty -a | grep dsusp >/dev/null 2>&1; then
  function no_dsusp()
  {
    term_settings=$(stty -g)                      # Capture old termio params
    target_bin=$(type -P $1)                      # Capture target program
    shift                                         # Remove from pos. parameters
    stty dsusp undef                              # Disable DSUSP
    trap 'rc=$?; stty '"$term_settings"'; exit $rc' 0 1 2 3 15
                                                  # Restore termios on interrupt
    $target_bin "$@"                              # Run target program
    stty $term_settings                           # Restore termios on exit
  }

  hash mutt >/dev/null 2>&1 && alias mutt="no_dsusp $(type -P mutt) && mbsync inboxes"
  hash neomutt >/dev/null 2>&1 && alias mutt="no_dsusp $(type -P neomutt) && mbsync inboxes"
  hash newsboat >/dev/null 2>&1 && alias newsboat="no_dsusp $(type -P newsboat)"
fi

# $ tmux env -------------------------------------------------------------------
# TODO: re-enable this with sandboxd? (https://github.com/benvan/sandboxd)
# Update shell environment variables within a session
# per https://raimue.blog/2013/01/30/tmux-update-environment/
# if hash tmux >/dev/null 2>&1; then
#   function tmux() {
#     tmux=$(type -P tmux)
#     case "$1" in
#       env)
#         [ -z "$TMUX" ] && return
# 
#         while read v; do
#           if [[ $v == -* ]]; then
#             unset ${v/#-/}
#           else
#             v=${v/=/=\"}
#             v=${v/%/\"}
#             eval export $v
#           fi
#         done < <(tmux show-environment)
#         ;;
#       *) $tmux "$@" ;;
#     esac
#   }
# fi

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

# gpg --------------------------------------------------------------------------
# # Update gpg-agent tty before SSH login
# if [ "$(type -t ssh)" = 'file' ]; then
#   ssh()
#   {
#     gpg-connect-agent updatestartuptty /bye >/dev/null 2>&1
#     $(type -P ssh) "$@"
#   }
# fi

# if [ "$(type -t scp)" = 'file' ]; then
#   scp()
#   {
#     gpg-connect-agent updatestartuptty /bye >/dev/null 2>&1
#     $(type -P scp) "$@"
#   }
# fi

# if [ "$(type -t lftp)" = 'file' ]; then
#   lftp()
#   {
#     gpg-connect-agent updatestartuptty /bye >/dev/null 2>&1
#     $(type -P lftp) "$@"
#   }
# fi

# ALIASES ======================================================================
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

# Alacritty --------------------------------------------------------------------
# alias light="ln -srf ~/.config/alacritty/alacritty-gruvbox.yml ~/.config/alacritty/alacritty.yml; alias vim=\"vim -c 'colorscheme gruvbox | set bg=light'\""
# alias dark="ln -srf ~/.config/alacritty/alacritty-hybrid.yml ~/.config/alacritty/alacritty.yml; unalias vim"

# Bundler ----------------------------------------------------------------------
alias b='bundle exec'
alias bj='bundle exec jekyll'

function bundle() {
  bundle="$(type -P bundle)"

  if [ -r "$BUNDLE_GEMFILE" ] && [ -r Gemfile ] && [ "$BUNDLE_GEMFILE" != Gemfile ] &&
     [[ "$1" =~ ^(|install|update)$ ]]; then
    BUNDLE_GEMFILE=Gemfile "$bundle" "$@"
    cp Gemfile.lock "${BUNDLE_GEMFILE}.lock"
  fi

  "$bundle" "$@"
}

# ranger -----------------------------------------------------------------------
# if [ -r "$HOME/.config/ranger/w3mimgdisplay" ]; then
#   export W3MIMGDISPLAY_PATH="$HOME/.config/ranger/w3mimgdisplay"
# fi
# if [ -r "$HOME/.config/ranger/rc.conf" ]; then
#   export RANGER_LOAD_DEFAULT_RC="FALSE"
# fi

# wakeonlan --------------------------------------------------------------------
if type wakeonlan >/dev/null 2>&1 && [ -d "$HOME/.config/pass/network/wol" ]; then
  function wol() {
    wakeonlan -i 192.168.0.255 $(pass "network/wol/$1")
  }
fi
