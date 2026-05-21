# -*- mode: sh -*-

# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

# User specific aliases and functions

alias l='longrun'
alias g-d='git diff'
alias g-am='git commit -a --amend --no-edit'
alias g-amr='git commit -a --amend'
alias g-c='git commit -a'
alias jhm='jhbuild make'
alias make='chrt --idle 0 make -j $(getconf _NPROCESSORS_ONLN)'
# This is better than `sudo make install` in that
# just like most package managers, it avoids running
# the Makefile as root, which can cause problems with
# things being *built* as root.
alias makesudoinstall='make && rm -rf _install && make install DESTDIR=$(pwd)/_install && sudo rsync -rlv _install/ / && rm -rf _install'
alias mock='chrt --idle 0 mock'
alias fedpkg='chrt --idle 0 fedpkg'
alias rhpkg='chrt --idle 0 rhpkg'

# https://unix.stackexchange.com/questions/79684/fix-terminal-after-displaying-a-binary-file
alias reset='/usr/bin/reset; stty sane; tput rs1; clear; echo -e "\033c"'

export PATH="$HOME/.local/bin:$PATH"
if test -z "${SSH_AUTH_SOCK:-}"; then
   export SSH_AUTH_SOCK=${XDG_RUNTIME_DIR}/keyring/ssh
fi

# ~/go is annoying
export GOPATH="$HOME"

HISTCONTROL=ignoreboth
export HISTSIZE=5000
shopt -s histappend

LAST_HISTORY_WRITE=$SECONDS
function save_history_prompt_command {
    if [ $(($SECONDS - $LAST_HISTORY_WRITE)) -gt 60 ]; then
        history -a && history -c && history -r
        LAST_HISTORY_WRITE=$SECONDS
    fi
}

if test -n "${PROMPT_COMMAND}"; then
  PROMPT_COMMAND="$PROMPT_COMMAND; save_history_prompt_command"
else
  PROMPT_COMMAND="save_history_prompt_command"
fi

if test -x /usr/bin/vim; then
    EDITOR=vim
else
    EDITOR=vi
fi
export EDITOR

bold=$(tput bold)
normal=$(tput sgr0)

# Last command status
_format_last_err ()
{
  local r=$?
  if ! [ $r -eq 0 ]; then
    echo -e -n '\e[1;31m[exit '$r']\e[0m '
  fi
}

# Only print the top two directories
_format_wd ()
{
  pwd=$(pwd)
  base=$(basename "$pwd")
  parent=$(basename $(dirname "$pwd"))
  pparent=$(basename $(dirname "$parent"))
  if test "$pparent" != "/"; then
    echo -n "$parent/";
    echo -n "$base";
  else
    if test "$parent" != "/"; then
      echo -n "/$parent/"
      echo -n "$base";
    else
      echo -n "/";
      echo -n "$base";
    fi
  fi
}

# Context is privileges, container vs not
_format_ctx () {
    if test -f /run/ostree-booted; then
        echo -n "${bold:-}host${normal:-}:${USER}@$(hostname -s) "
    else
        # entrypoint.sh in my dev containers writes /run/container
        if test -z "${container:-}" && test -f /run/container; then
            container=$(cat /run/container)
            export container
        fi
        if test -n "${container:-}"; then
            local osid=""
            if test -f /etc/os-release; then
                osid=$(. /etc/os-release && echo ${ID}${VERSION_ID})
            else
                osid=$(hostname -s)
            fi
            local privprefix=
            if command -v capsh &>/dev/null && capsh --print 2>/dev/null | grep -qEe '^Current.*cap_sys_admin'; then
                privprefix="${bold:-}priv${normal:-}"
            fi
            local user="${USER:-$(id -un)}"
            if test "${user}" = root; then
                user="${bold:-}${user}${normal:-}"
            fi
            echo -n "${privprefix}container:${user}@${osid} "
        fi
    fi
}

PS1_PREFIX='$(_format_last_err)$(_format_ctx)$(_format_wd)'

have_git_ps1=false
if test -f /usr/share/git-core/contrib/completion/git-prompt.sh; then
  source /usr/share/git-core/contrib/completion/git-prompt.sh
  have_git_ps1=true
elif test -f /usr/lib/git-core/git-sh-prompt; then
  # Debian/Ubuntu location
  source /usr/lib/git-core/git-sh-prompt
  have_git_ps1=true
elif test -n "$BASH_COMPLETION" && test -f /etc/bash_completion.d/git; then
  have_git_ps1=true
fi

# https://github.com/euank/pazi/
if command -v pazi &>/dev/null; then
    eval "$(pazi init bash)"
fi

if $have_git_ps1; then
  PS1_PREFIX="$PS1_PREFIX"'$(__git_ps1 " [git %s]")'
fi

PS1="$PS1_PREFIX"'\n\$ '
export PS1


# Keep in sync with env.nu
export GOOGLE_CLOUD_PROJECT="itpc-gcp-core-pe-eng-claude"
export VERTEX_LOCATION="global"
export GOOGLE_CLOUD_LOCATION="global"
