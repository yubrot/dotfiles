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
  export PATH=/Applications/MacVim.app/Contents/MacOS:$PATH
  export EDITOR=/Applications/MacVim.app/Contents/MacOS/Vim
  alias vim='Vim'

  alias cp='cp -apR'
  alias scp='scp -r'

  use_exa_as_ls
  ;;
linux*)
  export EDITOR=/usr/bin/vim

  alias cp='cp -apr'
  alias scp='scp -r'

  use_exa_as_ls
  ;;
esac

alias c='cd ..'
alias v='vim'
alias g='git'
alias lss='ls -lh'
alias mkdir='mkdir -p'
alias zip='zip -r'
alias testserver='python -m http.server'
alias -g H=' | head'
alias -g T=' | tail'
alias -g G=' | grep'
alias -g L=' | less'

chpwd() {
  s
}

cdroot() {
  cd `git rev-parse --show-toplevel`
}

fignore=(.o .obj .bak .hi .deps .meta .asset .mdb .sln .unity)

export PATH=$HOME/.local/bin:$PATH
export LD_LIBRARY_PATH=/usr/local/lib:$LD_LIBRARY_PATH

hash -d dl=~/Downloads
hash -d box=~/Dropbox

# OCaml
. $HOME/.opam/opam-init/init.zsh > /dev/null 2> /dev/null || true

# Haskell
alias ghc='stack ghc --'
alias ghci='stack ghci --'
alias runghc='stack runghc --'
alias stacktest='stack test --file-watch --coverage --fast'

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

# Scala
alias sbt='TERM=xterm sbt'

# Objective-C
alias objc='clang -fobjc-arc -fobjc-exceptions -fobjc-arc-exceptions -w -framework Foundation'

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

setopt prompt_subst
setopt IGNOREEOF
WORDCHARS='*?_-.[]~=&;!#$%^(){}<>'
stty stop undef
PROMPT='%{${fg[green]}%}[%n@%m %~]%{${reset_color}%}
%(!.#.$) '

umask 022

autoload -Uz zmv
alias zmv='noglob zmv -w'

precmd() {
  print -Pn "\e]0;%n@%m %~\a %(!.#.$)"
}

source ~/.config/zsh/auto-fu.zsh
source ~/.config/zsh/auto-fu-ext.zsh

zle-line-init () { auto-fu-init; }
zle -N zle-line-init

zstyle ':auto-fu:highlight' input bold
zstyle ':auto-fu:var' postdisplay $''
zstyle ':auto-fu:var' disable magic-space
zstyle ':auto-fu:var' autoable-function/skiplbuffers \
  'yay *' 'pacman *' 'sudo pacman *' 'adb * *' 'g *' \
  'stack * *' 'd * *' 'dc * *' 'k * *' 'npm *' 'java *' \
  'journalctl *' 'scp *' 'rsync *' 'rustc *' './gradlew *' \
  './bin/rails *' './bin/rake *' 'brew *'

source ~/.config/zsh/vcs-info.zsh
source ~/.local.zsh

