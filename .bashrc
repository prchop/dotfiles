#!/bin/bash
# shellcheck disable=SC1090,SC1091
#
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

set-editor() {
	export EDITOR="$1"
	export VISUAL="$1"
	export GH_EDITOR="$1"
	export GIT_EDITOR="$1"
	alias vi="\$EDITOR"
}
_have "vim" && set-editor vi
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
} && export envx

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
} && export clone

pathprepend() {
	for arg in "$@"; do
		test -d "$arg" || continue
		PATH=${PATH//:"$arg:"/:}
		PATH=${PATH/#"$arg:"/}
		PATH=${PATH/%":$arg"/}
		export PATH="$arg${PATH:+":${PATH}"}"
	done
} && export pathprepend

pathappend() {
	declare arg
	for arg in "$@"; do
		test -d "$arg" || continue
		PATH=${PATH//":$arg:"/:}
		PATH=${PATH/#"$arg:"/}
		PATH=${PATH/%":$arg"/}
		export PATH="${PATH:+"$PATH:"}$arg"
	done
} && export pathappend

# "$HOME/.local/go/bin" \
# /usr/local/bin \

pathprepend \
	"$BUN_INSTALL/bin" \
	"$CARGO_HOME/bin" \
	"$NVM_DIR/versions/node/$(node -v)/bin" \
	"$HOME/.deno/bin" \
	"$HOME/.local/go/bin" \
	"$HOME/.local/bin" \
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

set -o vi
shopt -s histappend

# alias
alias c='printf "\e[H\e[2J"'
alias codes='cd $CODE'
alias documents='cd $DOCUMENTS'
alias dot='cd $DOTFILES'
alias emacs='emacs -nw'
alias ghrepos='cd $GHREPOS'
alias path='echo -e "${PATH//:/\\n}"'
alias cdpath='echo -e "${CDPATH//:/\\n}"'
alias projects='cd $CODE/projects/'
alias scripts='cd $SCRIPTS'
alias todo='$EDITOR $DOCUMENTS/.todo.md'
alias temp='cd $(mktemp -d)'
alias '??'=google
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

# TMUX
if [ -z "$TMUX" ] && [ "$TERM" = "xterm-kitty" ]; then
	tmux attach || tmux new-session && exit
fi

# nvm
export NVM_DIR="$HOME/.config/nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"                   # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion" # This loads nvm bash_completion
