#!/bin/bash
# shellcheck disable=SC1090,SC1091

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

_have() { type "$1" &>/dev/null; }
_source_if() { [[ -r "$1" ]] && source "$1"; }

# --------------------------- smart prompt ---------------------------
# Copyright 2024 Robert S. Muhlestein (linktr.ee/rwxrob)

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
export DOCUMENTS="$HOME/Documents"
export DOWNLOADS="$HOME/Downloads"
export GOPATH="$HOME/go"
export GOBIN="$HOME/go/bin"
export BUN_INSTALL="$HOME/.bun"
export CARGO_HOME="$HOME/.cargo"
export BUNBIN="$BUN_INSTALL/bin"
export CARGOBIN="$CARGO_HOME/bin"
export GOPROXY=direct
export GCO_ENABLED=0
export NVIM_SCREENKEY=1

# for manual go install
# export GOPATH="$HOME/.local/go"
# export GOBIN="$HOME/.local/bin"

pathprepend() {
	for arg in "$@"; do
		test -d "$arg" || continue
		PATH=${PATH//:"$arg:"/:}
		PATH=${PATH/#"$arg:"/}
		PATH=${PATH/%":$arg"/}
		export PATH="$arg${PATH:+":${PATH}"}"
	done
} && export -f pathprepend

pathappend() {
	declare arg
	for arg in "$@"; do
		test -d "$arg" || continue
		PATH=${PATH//":$arg:"/:}
		PATH=${PATH/#"$arg:"/}
		PATH=${PATH/%":$arg"/}
		export PATH="${PATH:+"$PATH:"}$arg"
	done
} && export -f pathappend

pathprepend \
	"$HOME/.local/bin" \
	"$HOME/go/bin" \
	"$HOME/.bun/bin" \
	"$HOME/.cargo/bin" \
	"$HOME/.config/nvm/versions/node/$(node -v)/bin" \
	/usr/local/bin \
	"$SCRIPTS"
# "$HOME/.local/go/bin" \

pathappend \
	/usr/local/bin \
	/usr/local/sbin \
	/usr/sbin \
	/usr/bin \
	/sbin \
	/bin

# vi mode
set -o vi

# alias
alias path='echo -e "${PATH//:/\\n}"'
alias scripts='cd $SCRIPTS'
alias ghrepos='cd $GHREPOS'
alias c='printf "\e[H\e[2J"'

# cargo envpath
#. "$HOME/.cargo/env"

# personal and private bashrc config
_source_if "$HOME/.bash_personal"

# TMUX-attach
if [ -z "$TMUX" ] && [ "$TERM" = "xterm-kitty" ]; then
	tmux attach || tmux new-session -s home && exit
fi

# nvm
export NVM_DIR="$HOME/.config/nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"                   # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion" # This loads nvm bash_completion
