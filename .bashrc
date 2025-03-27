#!/bin/bash
# shellcheck disable=SC1090,SC1091

#set -x
test -s ~/.alias && . ~/.alias || true

_have() { type "$1" &>/dev/null; }
_source_if() { [[ -r "$1" ]] && source "$1"; }

# ======================
# ==== SMART PROMPT ====
# ======================
# Copyright 2024 Robert S. Muhlestein (github/rwxrob/dot)

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

set-editor() {
	export EDITOR="$1"
	export VISUAL="$1"
	export GH_EDITOR="$1"
	export GIT_EDITOR="$1"
	alias vi="\$EDITOR"
}
_have "vim" && set-editor vi
_have "nvim" && set-editor nvim

fpicker() {
	local files=()
	local preview_cmd="bat --color=always --style=numbers --line-range=:500 {}"
	local max="${1:-4}"
	shift
	local search_paths=("$PWD" "$REPOS" "$DOCUMENTS" "$CODE" "$@")

	# Find files and use fzf for selection
	mapfile -t files < <(
		find "${search_paths[@]}" \
			-maxdepth "$max" -name ".git" \
			-prune -o -type f -print 2>/dev/null |
			fzf --preview="$preview_cmd" \
				--query="$*" --multi --select-1 --exit-0
	)

	if [[ ${#files[@]} -eq 0 ]]; then
		echo "No file selected." >&2
		return 1
	fi

	# Open selected files
	"${EDITOR:-vim}" "${files[@]}"
	printf '%s\n' "${files[0]}"
}
_have fzf && _have bat && export fpicker

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
