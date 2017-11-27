# shellcheck disable=SC1090,SC2155

# PER-PLATFORM CONFIGURATION ===================================================
# Mac OS -----------------------------------------------------------------------
if [ "`uname`" = Darwin ]; then

  # ls colors
  export CLICOLOR=1

  # Prevent tmux from recomposing PATH
  # per http://superuser.com/a/583502
  export PATH='' && . /etc/profile

  # Add directories to PATH explicitly, idempotently
  for dir in \
    "$HOME/Scripts/Mac" \
    "$HOME/Library/Python/3.6/bin" \
    "$HOME/Library/Android/sdk/platform-tools" \
    "/usr/local/opt/gpg/libexec" \
    "/Applications/MacVim.app/Contents/MacOS" \
    "/System/Library/Frameworks/JavaScriptCore.framework/Versions/A/Resources"
  do
    if [ -d "$dir" ]; then
      case "$PATH" in
        *"$dir"*) :;;
        *) export PATH="$dir:$PATH";;
      esac
    fi
  done

  # Prevent `GitHub API rate limit exceeded` error
  # per https://gist.github.com/christopheranderton/8644743
  if command -v brew >/dev/null 2>&1; then
    export HOMEBREW_GITHUB_API_TOKEN=`cat "$HOME/.config/env/homebrew_github_api_token" >/dev/null 2>&1`
  fi

# Linux ------------------------------------------------------------------------
elif [ "`uname`" = Linux ]; then

  for dir in \
    "$HOME/bin" \
    "$HOME/.local/bin" \
    "$HOME/Scripts/Linux" \
    "/usr/lib/gnupg"
  do
    if [ -d "$dir" ]; then
      case "$PATH" in
        *"$dir"*) :;;
        *) export PATH="$dir:$PATH";;
      esac
    fi
  done

  # openSUSE -------------------------------------------------------------------
  if [ -r /etc/SUSE-brand ]; then
    [ -z "$PROFILEREAD" ] && . /etc/profile

  # Debian ---------------------------------------------------------------------
  # elif [ -r /etc/debian_version ]; then
  #   # the default umask is set in /etc/profile; for setting the umask
  #   # for ssh logins, install and configure the libpam-umask package.
  #   # umask 022
  
  fi
fi

# USER SETTINGS ================================================================

command -v vim >/dev/null 2>&1 && export EDITOR=vim || export EDITOR=vi
export VISUAL="$EDITOR"

if [ "$EDITOR" = 'vim' ]; then
  export MANPAGER="/bin/sh -c \"col -b | vim -c 'runtime ftplugin/man.vim | set ft=man ro nomod nolist iskeyword+=:' -\""
fi

for dir in \
  "$HOME/Scripts" \
  "$HOME/.cargo/bin" \
  "$HOME/.fzf/bin"
do
  if [ -d "$dir" ]; then
    case "$PATH" in
      *"$dir"*) :;;
      *) export PATH="$dir:$PATH";;
    esac
  fi
done

# APPLICATION SETTINGS =========================================================
# less -------------------------------------------------------------------------
export LESSHISTFILE=-

# ri ---------------------------------------------------------------------------
if [ -d "$HOME/.config/.vim/plugged/vim-plugin-AnsiEsc" ]; then
  export RI=-afansi
  export RI_PAGER="vim -c 'nnoremap <buffer> <silent> q :q!<CR> | AnsiEsc' -M -"
fi

# terminfo ---------------------------------------------------------------------
if [ -d "$HOME/.config/terminfo" ]; then
  export TERMINFO="$HOME/.config/terminfo"
fi

# pass -------------------------------------------------------------------------
if command -v pass >/dev/null 2>&1; then
  export PASSWORD_STORE_DIR="$HOME/.config/pass"
  export PASSWORD_STORE_EXTENSIONS_DIR="$HOME/.config/pass/ext"
fi

# lftp -------------------------------------------------------------------------
if [ -d "$HOME/.config/lftp" ]; then
  export LFTP_HOME="$HOME/.config/lftp"
fi

# GnuPG ------------------------------------------------------------------------
if [ -d "$HOME/.config/gnupg" ]; then
  export GNUPGHOME="$HOME/.config/gnupg"
fi

if command -v gpgconf >/dev/null 2>&1; then
  export SSH_AUTH_SOCK="`gpgconf --list-dirs agent-ssh-socket`"
  if [ -n "$SSH_AUTH_SOCK" ]; then
    gpgconf --launch gpg-agent
  fi
fi

# for pinentry-curses
# export GPG_TTY=$(tty)
# Force pinentry-curses in SSH sessions
# (https://gpgtools.tenderapp.com/kb/faq/enter-passphrase-with-pinentry-in-terminal-via-ssh-connection)
# [ -n "$SSH_CONNECTION" ] && export PINENTRY_USER_DATA="USE_CURSES=1"

# fzf --------------------------------------------------------------------------
if command -v fzf >/dev/null 2>&1; then
  export FZF_DEFAULT_COMMAND=`(command -v fd >/dev/null 2>&1 && printf 'fd -tf') || \
                              (command -v rg >/dev/null 2>&1 && printf 'rg --files') || \
                              (command -v ag >/dev/null 2>&1 && printf 'ag -g ""')`
fi

# rtv --------------------------------------------------------------------------
if command -v rtv >/dev/null 2>&1 && hash urlscan >/dev/null 2>&1; then
   export RTV_URLVIEWER="`hash -t urlscan`"
fi

# littleredflag ----------------------------------------------------------------
# if command -v littleredflag >/dev/null 2>&1; then
#   mkdir -p "$HOME/.tmp"
#   PIDFILE="$HOME/.tmp/littleredflag.pid"

#   if [ -e "${PIDFILE}" ] && (ps -u $(whoami) -opid= |
#                              grep "$(cat ${PIDFILE})" &> /dev/null); then
#     :
#   else
#     littleredflag -v inboxes 2> /dev/null > "$HOME/.tmp/littleredflag.log" &

#     echo $! > "${PIDFILE}"
#     chmod 644 "${PIDFILE}"
#   fi
# fi
