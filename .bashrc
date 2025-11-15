#!/bin/bash
# shellcheck disable=SC1090,SC1091
#
# There are 3 different types of shells in bash: the login shell, normal shell
# and interactive shell. Login shells read ~/.profile and interactive shells
# read ~/.bashrc; in our setup, /etc/profile sources ~/.bashrc - thus all
# settings made here will also take effect in a login shell.
#
# NOTE: It is recommended to make language settings in ~/.profile rather than
# here, since multilingual X sessions would not work properly if LANG is over-
# ridden in every subshell.
# set -x

case $- in
*i*) ;; # interactive
*) return ;;
esac

test -s ~/.alias && . ~/.alias || true

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
	long="${g}╔ $u\u$g$PROMPT_AT$h\h$g:$w$dir$B\n${g}╚ $p$P$x "
	double="${g}╔ $u\u$g$PROMPT_AT$h\h$g:$w$dir\n${g}║ $B\n${g}╚ $p$P$x "

	if ((${#countme} > PROMPT_MAX)); then
		PS1="$double"
	elif ((${#countme} > PROMPT_LONG)); then
		PS1="$long"
	else
		PS1="$short"
	fi

	[[ "${VENVS[$PWD]}" =~ ^y ]] && PS1="${PS1//\$/🐍}"

	# if _have tmux && [[ -n "$TMUX" ]]; then
	# 	tmux rename-window "$(wd)"
	# fi
}

wd() {
	dir="${PWD##*/}"
	parent="${PWD%"/${dir}"}"
	parent="${parent##*/}"
	echo "$parent/$dir"
} && export wd

found-venv() { test -e .venv/bin/activate; }
venv-is-on() { [[ "$(command -v python)" =~ \.venv\/bin\/python$ ]]; }

declare -A VENVS
export VENVS

llvenv() {
	found-venv || return
	venv-is-on && return
	test -n "${VENVS[$PWD]}" && return
	read -rp "Want to activate the .venv? [Y/n]" answer
	answer=${answer,,}
	test -z "$answer" && answer=y
	VENVS["$PWD"]="$answer"
	if [[ $answer =~ ^y ]]; then
		. .venv/bin/activate
	fi
}

PROMPT_COMMAND="llvenv;__ps1"

# ===============================
# ==== ENVIRONMENT VARIABLES ====
# ===============================

export USER="${USER:-$(whoami)}"
export GITUSER="$USER"
export REPOS="$HOME/Repos"
export GHREPOS="$REPOS/github.com/$GITUSER"
export DOTFILES="$GHREPOS/dotfiles"
export SCRIPTS="$HOME/Scripts"
export DOCUMENTS="$HOME/Documents"
export CODE="$HOME/Code"
export DOWNLOADS="$HOME/Downloads"
export BUN_INSTALL="$HOME/.bun"
export CARGO_HOME="$HOME/.cargo"
export GOPATH="$HOME/.local/share/go"
export GOBIN="$HOME/.local/bin"
export GOPROXY=direct
export CGO_ENABLED=0
export PYTHONDONTWRITEBYTECODE=2
# export TERM="xterm-256color"
# export COLORTERM="truecolor"

set-editor() {
	export EDITOR="$1"
	export VISUAL="$1"
	export GH_EDITOR="$1"
	export GIT_EDITOR="$1"
	alias v="\$EDITOR"
}
_have "vim" && set-editor vim
_have "nvim" && set-editor nvim

# export without -f work in bash 4.3+
envx() {
	local envfile="${1:-"$HOME/.env"}"
	[[ ! -e "$envfile" ]] && echo "$envfile not found" && return 1
	while IFS= read -r line; do
		name=${line%%=*}
		value=${line#*=}
		[[ -z "${name}" || $name =~ ^# ]] && continue
		export "$name"="$value"
	done <"$envfile"
} && export -f envx

[[ -e "$HOME/.env" ]] && envx "$HOME/.env"

clone() {
	local repo="$1" user
	local repo="${repo#https://github.com/}"
	local repo="${repo#git@github.com:}"
	if [[ $repo =~ / ]]; then
		user="${repo%%/*}"
	else
		user="$GITUSER"
		[[ -z "$user" ]] && user="$USER"
	fi
	local name="${repo##*/}"
	local userd="$REPOS/github.com/$user"
	local path="$userd/$name"
	[[ -d "$path" ]] && cd "$path" && return
	mkdir -p "$userd"
	cd "$userd"
	echo gh repo clone "$user/$name" -- --recurse-submodule
	gh repo clone "$user/$name" -- --recurse-submodule
	cd "$name"
} && export -f clone

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
	"$BUN_INSTALL/bin" \
	"$CARGO_HOME/bin" \
	"$NVM_DIR/versions/node/$(node -v)/bin" \
	"$HOME/.deno/bin" \
	"$HOME/.local/go/bin" \
	"$HOME/.local/bin" \
	/usr/local/go/bin \
	/usr/local/bin \
	"$SCRIPTS" \
	"$HOME/.config/emacs/bin"

pathappend \
	/usr/local/bin \
	/usr/local/sbin \
	/usr/sbin \
	/usr/bin \
	/sbin \
	/bin

# cd path
export CDPATH=".:$GHREPOS:$DOTFILES:$REPOS:$HOME"

# history
export HISTCONTROL=ignoreboth
export HISTSIZE=5000
export HISTFILESIZE=10000

# shopt is for BASHOPTS, set is for SHELLOPTS
set -o vi
shopt -s expand_aliases
shopt -s histappend
shopt -s globstar
shopt -s dotglob
shopt -s extglob

# alias
alias c='printf "\e[H\e[2J"'
alias codes='cd $CODE'
alias docs='cd $DOCUMENTS'
alias dot='cd $DOTFILES'
alias e='emacs -nw'
alias ghrepos='cd $GHREPOS'
alias gp='git push'
alias neo='neo -D -c gold'
alias note='cd $DOCUMENTS/tmpnotes/'
alias out='loginctl terminate-user $USER'
alias path='echo -e "${PATH//:/\\n}"'
alias cdpath='echo -e "${CDPATH//:/\\n}"'
alias projects='cd $CODE/projects/'
alias py='python3'
alias reload='exec $SHELL -l'
alias scripts='cd $SCRIPTS'
alias todo='$EDITOR $DOCUMENTS/tmpnotes/.todo.md'
alias temp='cd $(mktemp -d)'
alias '?'=brave
alias '??'=brave-lynx
alias '???'=chat
alias work="timer -f 50m -n '🔥️ Time to Work' && \
	paplay /usr/share/sounds/freedesktop/stereo/complete.oga \
	&& notify-send -u normal -i ~/.local/share/icons/tomato.png \
	'Pomodoro' 'Work Timer is up! Take a rest 😴️'"
alias rest="timer -f 10m -n '☕️ Time to Rest' && \
	paplay /usr/share/sounds/freedesktop/stereo/complete.oga \
	&& notify-send -u normal -i ~/.local/share/icons/tomato.png \
	'Pomodoro' 'Break is over! Get back to work 😬'"

# personal and private bashrc config
_source_if "$HOME/.bash_personal"

# source external completion
_have timer && . <(timer completion bash)
_have pandoc && . <(pandoc --bash-completion)
_have dlv && . <(dlv completion bash)
_have sqlc && . <(sqlc completion bash)

# disable internal keyboard
# _have keyboard && keyboard off
#_have xmodmap && xmodmap -e "keycode 113 = NoSymbol"

# dir colors
if _have dircolors; then
	if [[ -r "$HOME/.dircolors" ]]; then
		eval "$(dircolors -b "$HOME/.dircolors")"
	else
		eval "$(dircolors -b)"
	fi
fi

# TMUX
if [[ -z "$TMUX" && "$TERM" = "xterm-ghostty" ]]; then
	tmux attach || tmux && exit
fi

# nvm
export NVM_DIR="$HOME/.config/nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"                   # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion" # This loads nvm bash_completion
