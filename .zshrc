HISTFILE=~/.histfile
HISTSIZE=1000000
SAVEHIST=1000000

bindkey -e
zstyle :compinstall filename '~/.zshrc'

use_exa_as_ls() {
  alias ls='exa -F --group-directories-first'
  alias la='ls -a'
  alias s='ls --git-ignore -I "*.meta"'
}

case "${OSTYPE}" in
darwin*)
  alias cp='cp -apR'
  alias scp='scp -r'

  use_exa_as_ls
  ;;
linux*)
  alias cp='cp -apr'
  alias scp='scp -r'

  use_exa_as_ls

  export DISPLAY=$(cat /etc/resolv.conf | grep nameserver | awk '{print $2}'):0
  ;;
esac

alias c='cd ..'
alias cdr='cdroot'
alias v='vim'
alias g='git'
alias lss='ls -lh'
alias mkdir='mkdir -p'
alias zip='zip -r'
alias testserver='python -m http.server'
alias -g G=' | grep'

export EDITOR=/usr/bin/vim

chpwd() {
  s
}

cdroot() {
  cd `git rev-parse --show-toplevel`
}

fignore=(.o .obj .bak .hi .deps .meta .asset .mdb .sln .unity)

export PATH=$HOME/.local/bin:$PATH
export LD_LIBRARY_PATH=/usr/local/lib:$LD_LIBRARY_PATH

# OCaml
. $HOME/.opam/opam-init/init.zsh >/dev/null 2>&1 || true

# Haskell
[ -f "${GHCUP_INSTALL_BASE_PREFIX:=$HOME}/.ghcup/env" ] && source "${GHCUP_INSTALL_BASE_PREFIX:=$HOME}/.ghcup/env"

# LLVM
export LLVMENV_RUST_BINDING=1
command -v llvmenv >/dev/null 2>&1 && source <(llvmenv zsh)

# Ruby
export RBENV_SHELL=zsh
export GEM_HOME=$HOME/.gem
export PATH=$HOME/.rbenv/shims:$HOME/.gem/bin:$PATH

# Go
export GO111MODULE=on
export GOROOT=/usr/lib/go
export GOPATH=$HOME/.go
export PATH=$GOPATH/bin:$PATH

# Rust
export PATH=$HOME/.cargo/bin:$PATH

# Node
export PATH=$HOME/.nodebrew/current/bin:$PATH

# .NET
export DOTNET_SKIP_FIRST_TIME_EXPERIENCE=true
export DOTNET_CLI_UI_LANGUAGE=en-us
export PATH=$HOME/.dotnet/tools:$PATH
alias dot='TERM=xterm dotnet'

# Java
export PATH="$HOME/.jenv/bin:$PATH"
eval "$(jenv init -)"

# Scala
alias sbt='TERM=xterm sbt'
export PATH=$HOME/Library/Application\ Support/Coursier/bin:$PATH
export PATH=$HOME/.local/share/coursier/bin:$PATH

# Docker
alias d='docker'
alias dc='docker-compose'
alias dr='d run --rm -it'
alias dcr='dc run --rm'
alias dl='d ps -lq'
alias dex='d exec -it'
dclean() {
  d rm `d ps -aq`
  d volume rm `d volume ls -f dangling=true -q`
  d rmi `d images -f dangling=true -q`
}
alias k='kubectl'
alias kr='k run --rm -it --restart=Never'
alias kex='k exec -it'

# gcloud
export CLOUDSDK_PYTHON=/usr/bin/python2
export PATH=$HOME/.google-cloud-sdk/bin:$PATH
if [ -f "$HOME/.google-cloud-sdk/path.zsh.inc" ]; then . "$HOME/.google-cloud-sdk/path.zsh.inc"; fi
if [ -f "$HOME/.google-cloud-sdk/completion.zsh.inc" ]; then . "$HOME/.google-cloud-sdk/completion.zsh.inc"; fi

bindkey '^f' forward-word
bindkey '^b' backward-word

autoload colors
colors

setopt auto_pushd
setopt list_types
setopt pushd_ignore_dups
setopt auto_remove_slash

autoload -Uz compinit
compinit

zstyle ':completion:*' accept-exact '*(N)'
zstyle ':completion:*:cd:*' ignore-parents parent pwd
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
zstyle ':completion:*' completer _oldlist _complete _ignored

setopt ignoreeof

WORDCHARS='*?_-.[]~=&;!#$%^(){}<>'

stty stop undef

umask 022

autoload -Uz zmv
alias zmv='noglob zmv -w'

precmd() {
  print -Pn "\e]0;%n@%m %~\a %(!.#.$)"
}

eval "$(starship init zsh)"
eval "$(direnv hook zsh)"

ZSH_AUTOSUGGEST_STRATEGY=(completion)
ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20
ZSH_AUTOSUGGEST_USE_ASYNC=true
[ -d /usr/local/share/zsh-autosuggestions ] && source /usr/local/share/zsh-autosuggestions/zsh-autosuggestions.zsh
[ -d /usr/share/zsh/plugins/zsh-autosuggestions ] && source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
# workaround https://github.com/zsh-users/zsh-autosuggestions/issues/512
_zsh_autosuggest_capture_postcompletion() {
  unset 'compstate[list]'
}
