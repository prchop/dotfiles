#!/bin/bash

# There are 3 different types of shells in bash: the login shell, normal shell
# and interactive shell. Login shells read ~/.profile and interactive shells
# read ~/.bashrc; in our setup, /etc/profile sources ~/.bashrc - thus all
# settings made here will also take effect in a login shell.
#
# NOTE: It is recommended to make language settings in ~/.profile rather than
# here, since multilingual X sessions would not work properly if LANG is over-
# ridden in every subshell.
#set -x
test -s ~/.alias && . ~/.alias || true

# eval "$(starship init bash)"

# --------------------------- smart prompt ---------------------------
# Copyright 2024 Robert S. Muhlestein (linktr.ee/rwxrob)

_have() { type "$1" &>/dev/null; }

PROMPT_LONG=20
PROMPT_MAX=95
PROMPT_AT=@

__ps1() {
	local P='$' dir="${PWD##*/}" B countme short long double \
		r='\[\e[31m\]' h='\[\e[34m\]' \
		u='\[\e[33m\]' p='\[\e[34m\]' w='\[\e[35m\]' \
		b='\[\e[36m\]' x='\[\e[0m\]' \
		g="\[\033[38;2;90;82;76m\]"

	[[ $EUID == 0 ]] && P='#' && u=$r && p=$u # root
	[[ $PWD = / ]] && dir=/
	[[ $PWD = "$HOME" ]] && dir='~'

	B=$(git branch --show-current 2>/dev/null)
	[[ $dir = "$B" ]] && B=.
	countme="$USER$PROMPT_AT$(hostname):$dir($B)\$ "

	[[ $B == master || $B == main ]] && b="$r"
	[[ -n "$B" ]] && B="$g($b$B$g)"

	short="$u\u$g$PROMPT_AT$h\h$g:$w$dir$B$p$P$x "
	long="${g}╔$u\u$g$PROMPT_AT$h\h$g:$w$dir$B\n${g}╚$p$P$x "
	double="${g}╔$u\u$g$PROMPT_AT$h\h$g:$w$dir\n${g}║$B\n${g}╚$p$P$x "

	if ((${#countme} > PROMPT_MAX)); then
		PS1="$double"
	elif ((${#countme} > PROMPT_LONG)); then
		PS1="$long"
	else
		PS1="$short"
	fi

	if _have tmux && [[ -n "$TMUX" ]]; then
		tmux rename-window "$(wd)"
	fi
}

wd() {
	dir="${PWD##*/}"
	parent="${PWD%"/${dir}"}"
	parent="${parent##*/}"
	echo "$parent/$dir"
} && export wd

PROMPT_COMMAND="__ps1"

# ===============================
# ==== ENVIRONMENT VARIABLES ====
# ===============================

export USER="${USER:-$(whoami)}"
export GITUSER="$USER"
export REPOS="$HOME/Repos"
export GHREPOS="$REPOS/github.com/$GITUSER"
export DOTFILES="$GHREPOS/dotfiles"
export SCRIPTS="$HOME/scripts"
export GOPRIVATE="github.com/$GITUSER/*,gitlab.com/$GITUSER/*"
# export GOPATH="$HOME/.local/go"
export GOBIN="$HOME/.local/bin"
export GCO_ENABLED=0
export BUN_INSTALL="$HOME/.bun"
export CARGO_HOME="$HOME/.cargo"
export PATH="$BUN_INSTALL/bin:$PATH"
export PATH="$CARGO_HOME/bin:$PATH"
#export PATH="$BUN_INSTALL/bin:$CARGO_HOME/bin:$PATH"

pathprepend() {
	for arg in "$@"; do
		test -d "$arg" || continue
		PATH=${PATH//:"$arg:"/:}
		PATH=${PATH/#"$arg:"/}
		PATH=${PATH/%":$arg"/}
		export PATH="$arg${PATH:+":${PATH}"}"
	done
} && export -f pathprepend

pathprepend \
	"$HOME/.local/bin" \
	/usr/local/bin \
	"$SCRIPTS"
# "$GHREPOS/cmd-"* \
# /opt/homebrew/bin \
# "$HOME/.local/go/bin" \
# /usr/local/go/bin \
# /usr/local/opt/openjdk/bin \

<<<<<<< HEAD
=======
# nvm
export NVM_DIR="$HOME/.config/nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"                   # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion" # This loads nvm bash_completion
>>>>>>> origin/main

# vi mode
set -o vi

# alias
alias path='echo -e "${PATH//:/\\n}"'
alias c='printf "\e[H\e[2J"'

# cargo envpath
#. "$HOME/.cargo/env"

# TMUX-attach
if [ -z "$TMUX" ] && [ "$TERM" = "xterm-kitty" ]; then
	tmux attach || tmux new-session -s home && exit
fi

# prevent duplicate path (dont now how to remove the duplicate path)
export PATH=$(echo $PATH | sed -e "s|$HOME/.config/nvm/versions/node/v22.13.1/bin:||g" -e "s|:$HOME/.config/nvm/versions/node/v22.13.1/bin||g")

if [[ ":$PATH:" != *":$HOME/.config/nvm/versions/node/v22.13.1/bin:"* ]]; then
  export PATH="$HOME/.config/nvm/versions/node/v22.13.1/bin:$PATH"
fi
