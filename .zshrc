# -----------------------
# Core
# -----------------------

HISTFILE=~/.histfile
HISTSIZE=1000000
SAVEHIST=1000000

bindkey -e
bindkey '^f' forward-word
bindkey '^b' backward-word

precmd() {
  print -Pn "\e]0;%n@%m %~\a %(!.#.$)"
}

setopt auto_pushd
setopt list_types
setopt pushd_ignore_dups
setopt auto_remove_slash
setopt ignoreeof

umask 022

stty stop undef

WORDCHARS='*?_-.[]~=&;!#$%^(){}<>'
fignore=(.o .obj .bak .hi .deps .meta .asset .mdb .sln .unity)

zstyle :compinstall filename '~/.zshrc'
zstyle ':completion:*' accept-exact '*(N)'
zstyle ':completion:*:cd:*' ignore-parents parent pwd
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
zstyle ':completion:*' completer _oldlist _complete _ignored

autoload -Uz compinit
compinit

ZSH_AUTOSUGGEST_STRATEGY=(completion)
ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20
ZSH_AUTOSUGGEST_USE_ASYNC=true
[ -d /opt/homebrew/share/zsh-autosuggestions ] && source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh
[ -d /usr/share/zsh/plugins/zsh-autosuggestions ] && source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
# workaround https://github.com/zsh-users/zsh-autosuggestions/issues/512
_zsh_autosuggest_capture_postcompletion() {
  unset 'compstate[list]'
}

autoload colors
colors

export PATH=$HOME/.local/bin:$PATH
export LD_LIBRARY_PATH=/usr/local/lib:$LD_LIBRARY_PATH

# Brew (for macOS)
command -v /opt/homebrew/bin/brew >/dev/null 2>&1 && eval "$(/opt/homebrew/bin/brew shellenv)"

# Mise
if command -v mise >/dev/null 2>&1; then
  case $- in
  *i*)
    eval "$(mise activate)"
    ;;
  *)
    eval "$(mise activate --shims)"
    ;;
  esac
fi

# -----------------------
# Tools
# -----------------------

case "${OSTYPE}" in
darwin*)
  alias cp='cp -apR'
  export EDITOR=/opt/homebrew/bin/nvim
  ;;
linux*)
  alias cp='cp -apr'
  export EDITOR=/usr/bin/nvim
  export DISPLAY=$(cat /etc/resolv.conf | grep nameserver | awk '{print $2}'):0
  ;;
esac

alias scp='scp -r'
alias c='cd ..'
alias ls='eza -F --group-directories-first'
alias la='ls -a'
alias s='ls --git-ignore'
alias v='nvim'
alias m='mise'
alias f='fzf'
alias g='git'
alias gg='lazygit'
alias q='ghq'
alias lss='ls -lh'
alias mkdir='mkdir -p'
alias zip='zip -r'

chpwd() {
  s
}

cdr() {
  builtin cd `git rev-parse --show-toplevel`
}

vf() {
  v "$(fd -H -t f -0 "$@" . | f --read0 -0 -1 -m)"
}

cf() {
  builtin cd "$(fd -H -t d -0 "$@" . | f --read0 -0 -1)"
}

qf() {
  builtin cd "$(q list -p | eval $(grep_and "$@") | f -0 -1)"
}

gf() {
  g b | eval $(grep_and "$@") | f -0 -1 | xargs git co
}

gfr() {
  g b -r | eval $(grep_and "$@") | f -0 -1 | xargs git co
}

grep_and() {
  local cmd="cat -"
  for v in "$@"; do
    cmd+=" | grep -e \"$v\""
  done
  echo "$cmd"
}

# Docker
alias d='docker'
alias dc='docker compose'
alias dr='d run --rm -it'
alias dcr='dc run --rm'
alias dl='d ps -lq'
alias dex='d exec -it'
dclean() {
  d rm `d ps -aq`
  d volume rm `d volume ls -f dangling=true -q`
  d rmi `d images -f dangling=true -q`
}

# Kubernetes
alias k='kubectl'
alias kr='k run --rm -it --restart=Never'
alias kex='k exec -it'

# gcloud
export PATH=$HOME/.google-cloud-sdk/bin:$PATH
if [ -f "$HOME/.google-cloud-sdk/path.zsh.inc" ]; then . "$HOME/.google-cloud-sdk/path.zsh.inc"; fi
if [ -f "$HOME/.google-cloud-sdk/completion.zsh.inc" ]; then . "$HOME/.google-cloud-sdk/completion.zsh.inc"; fi

# GO
export GOPATH=$HOME/.go

# -----------------------

eval "$(starship init zsh)"

