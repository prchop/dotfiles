#!/bin/bash
# shellcheck disable=SC1090,SC1091
#
#set -x

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
	if [[ "$1" == "session" ]]; then
		test -z "$dir" && echo "$parent" || echo "$dir"
	else
		echo "$parent/$dir"
	fi
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
export CODE="$HOME/Code"
export DOWNLOADS="$HOME/Downloads"
export GOPATH="$HOME/go"
export GOBIN="$HOME/go/bin"
export BUN_INSTALL="$HOME/.bun"
export CARGO_HOME="$HOME/.cargo"
export BUNBIN="$BUN_INSTALL/bin"
export CARGOBIN="$CARGO_HOME/bin"
export GOPROXY=direct
export GCO_ENABLED=0
# export NVIM_SCREENKEY=1

# for manual go install
# export GOPATH="$HOME/.local/go"
# export GOBIN="$HOME/.local/bin"

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
fpicker() {
	local preview_cmd="bat --color=always --style=numbers --line-range=:500 {}"
	local pattern="${1:-*}"
	shift
	local search_paths=("$PWD" "$REPOS" "$CODE" "$DOCUMENTS")

	# find matching files
	local files=()
	mapfile -t files < <(
		find "${search_paths[@]}" -type d \( -name ".git" -o -name "node_modules" \) \
			-prune -o -type f -name "$pattern" -print 2>/dev/null |
			fzf --preview="$preview_cmd" --multi --select-1 --exit-0
	)

	# empty selection
	[[ ${#files[@]} -eq 0 ]] && {
		echo "No file selected." >&2
		return 1
	}

	# open selected files
	"${EDITOR:-vim}" "${files[@]}"
	printf '%s\n' "${files[0]}"
}
_have fzf && _have bat && export fpicker

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
alias ghrepos='cd $GHREPOS'
alias path='echo -e "${PATH//:/\\n}"'
alias projects='cd $CODE/projects/'
alias scripts='cd $SCRIPTS'
alias '??'=google

# cargo envpath
#. "$HOME/.cargo/env"

# personal and private bashrc config
_source_if "$HOME/.bash_personal"

# TMUX
if [ -z "$TMUX" ] && [ "$TERM" = "xterm-kitty" ]; then
	tmux attach || tmux new-session && exit
fi

if _have tmux && [[ -n "$TMUX" ]]; then
	current_session=$(tmux display-message -p "#S")
	session_name="$(wd session)"
	if [[ "$current_session" =~ ^[0-9]+$ ]] &&
		! tmux has-session -t "$session_name" 2>/dev/null; then
		tmux rename-session "$(wd session)"
	fi
fi

# nvm
export NVM_DIR="$HOME/.config/nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"                   # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion" # This loads nvm bash_completion
