# shellcheck disable=SC2153,SC1090
# GUARD CLAUSE =================================================================
# Only run for interactive shells
[[ $- =~ i ]] || return

# STAGING ======================================================================

# INITIALIZATION ===============================================================
if [ "$(ps -o comm= $PPID)" = fbterm ]; then
  export TERM=fbterm
  source "$HOME/.config/fbterm/colors/hybrid" >/dev/null 2>&1
fi

if [ -z "$SSH_CONNECTION" ]; then
  # if in virtual terminal, start fbterm (with 256 color support)
  if type fbterm >/dev/null 2>&1 && [[ "$(tty)" =~ /dev/tty ]]; then
    fbterm
  # otherwise, start tmux / initialize tmux plugins
  elif type tmux >/dev/null 2>&1; then
    if [ -z "$TMUX" ]; then
      tmux new -As work
    elif [ "$(uname)" = Linux ] || type greadlink >/dev/null 2>&1; then
      source "$HOME/.config/tmux/tmux-git/init.sh" >/dev/null 2>&1
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
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# PER-PLATFORM CONFIGURATION ===================================================
# Linux ------------------------------------------------------------------------
if [ "$(uname)" = Linux ]; then
  # Provides programmable tab-completion for, e.g., git branch names.
  # May be redundant if already sourced in /etc/bash.bashrc (via /etc/profile).
  if ! shopt -oq posix; then
    for f in /{usr/share/bash-completion,etc}/bash_completion; do
      if [ -r "$f" ]; then source "$f"; break; fi
    done
  fi

  # Debian ---------------------------------------------------------------------
  if [ -r /etc/debian_version ]; then
    # make less more friendly for non-text input files, see lesspipe(1)
    #[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"
    
    # set variable identifying the chroot you work in (used in the prompt below)
    if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
      debian_chroot=$(cat /etc/debian_chroot)
    fi

    # Power Management ---------------------------------------------------------
    if type systemctl >/dev/null 2>&1; then
      if [ -z "$(type -t halt)" ];   then alias halt="systemctl poweroff";  fi
      if [ -z "$(type -t susp)" ];   then alias susp="systemctl suspend";   fi
      if [ -z "$(type -t hbnt)" ];   then alias hbnt="systemctl hibernate"; fi
      if [ -z "$(type -t reboot)" ]; then alias reboot="systemctl reboot";  fi
    fi

    # shellcheck disable=SC2139
    if type upower >/dev/null 2>&1; then
      alias batt="upower -i $(upower -e | grep battery) | grep \"time to empty\" | sed \"s/^[ \t]*time to empty:[ \t]*//\" -"
    fi

    # Colors -------------------------------------------------------------------
    # set a fancy prompt (non-color, unless we know we "want" color)
    # case "$TERM" in
    #     xterm-color|*-256color|fbterm) color_prompt=yes;;
    # esac
     
    # uncomment for a colored prompt, if the terminal has the capability; turned
    # off by default to not distract the user: the focus in a terminal window
    # should be on the output of commands, not on the prompt
    # force_color_prompt=yes
     
    # if [ -n "$force_color_prompt" ]; then
    #     if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
    #       # We have color support; assume it's compliant with Ecma-48
    #       # (ISO/IEC-6429). (Lack of such support is extremely rare, and such
    #       # a case would tend to support setf rather than setaf.)
    #       color_prompt=yes
    #     else
    #       color_prompt=
    #     fi
    # fi
     
    # if [ "$color_prompt" = yes ]; then
    #     PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
    # else
    #     PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
    # fi
    # unset color_prompt force_color_prompt
     
    # enable color support of ls and also add handy aliases
    if [ -x /usr/bin/dircolors ]; then
        test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
        alias ls='ls --color=auto'
        #alias dir='dir --color=auto'
        #alias vdir='vdir --color=auto'
     
        #alias grep='grep --color=auto'
        #alias fgrep='fgrep --color=auto'
        #alias egrep='egrep --color=auto'
    fi
     
    # colored GCC warnings and errors
    # export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'
     
    # function EXT_COLOR () { echo -ne "\e[38;5;$1m"; }
    # function CLOSE_COLOR () { echo -ne '\e[m'; }
    # export PS1="\[`EXT_COLOR 187`\]\u@\h[`CLOSE_COLOR`\]\[`EXT_COLOR 174`\]:\w \$ \[`CLOSE_COLOR`\]"
    # export LS_COLORS='di=38;5;108:fi=00;*svn-commit.tmp=31:ln=38;5;116:ex=38;5;186'

    # GUI Term Options ---------------------------------------------------------
    # If this is an xterm set the title to user@host:dir
    case "$TERM" in
    xterm*|rxvt*)
        PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
        ;;
    *)
        ;;
    esac
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
# Update shell environment variables within a session
# per https://raimue.blog/2013/01/30/tmux-update-environment/
if hash tmux >/dev/null 2>&1; then
  function tmux() {
    tmux=$(type -P tmux)
    case "$1" in
      env)
        [ -z "$TMUX" ] && return

        while read v; do
          if [[ $v == -* ]]; then
            unset ${v/#-/}
          else
            v=${v/=/=\"}
            v=${v/%/\"}
            eval export $v
          fi
        done < <(tmux show-environment)
        ;;
      *) $tmux "$@" ;;
    esac
  }
fi

# $ brew find ------------------------------------------------------------------
# Interactively search-and-install formulae
if hash brew >/dev/null 2>&1; then
  function brew() {
    brew=$(type -P brew)
    if hash rg >/dev/null 2>&1; then
      grepprg='rg'
    elif hash ag >/dev/null 2>&1; then
      grepprg='ag'
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

# Bundler ----------------------------------------------------------------------
alias b='bundle exec'
alias bj='bundle exec jekyll'
