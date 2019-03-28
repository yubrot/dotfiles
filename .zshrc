HISTFILE=~/.histfile
HISTSIZE=1000000
SAVEHIST=1000000

bindkey -e
zstyle :compinstall filename '~/.zshrc'

use_exa_as_ls() {
  alias ls='exa -F'
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
msys*)
  export PATH=$HOME/AppData/Roaming/local/bin:$PATH
  export EDITOR=/usr/bin/vim

  alias cp='cp -apr'
  alias scp='scp -r'

  alias ls='ls -XF --color=auto'
  alias la='ls -A'
  alias s='ls -I "*.meta" -I "ntuser.*" -I "NTUSER.*" -I "Application Data" -I Contacts -I "3D Objects" -I Favorites -I "Local Settings" -I OneDrive -I PrintHood -I "Saved Games" -I Cookies -I Links -I NetHood -I Recent -I Searches -I SendTo -I Templates -I Tracing -I "My Documents" -I Videos -I "スタート メニュー" -I "\$Recycle.Bin"'

  export TMUX_TMPDIR=~/.tmux.tmp
  mkdir -p ~/.tmux.tmp
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

export LD_LIBRARY_PATH=/usr/local/lib:$LD_LIBRARY_PATH

hash -d dl=~/Downloads
hash -d box=~/Dropbox

# OCaml
. $HOME/.opam/opam-init/init.zsh > /dev/null 2> /dev/null || true

# Haskell
export PATH=$HOME/.local/bin:$PATH
alias ghc='stack ghc --'
alias ghci='stack ghci --'
alias runghc='stack runghc --'
alias stacktest='stack test --file-watch --coverage --fast'

# Ruby
export RBENV_SHELL=zsh
export GEM_HOME=$HOME/.gem
export PATH=$HOME/.rbenv/shims:$HOME/.gem/bin:$PATH

# Go
export GOPATH=$HOME/in/go
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
  'yaourt *' 'pacman *' 'sudo pacman *' 'adb * *' 'g *' \
  'stack * *' 'st *' 'j *' 'd * *' 'dc * *' 'npm *' 'java *' \
  'journalctl *' 'scp *' 'rsync *' 'rustc *' './gradlew *' \
  './bin/rails *' './bin/rake *' 'brew *'

source ~/.config/zsh/vcs-info.zsh
source ~/.local.zsh

# case $- in *i*)
#   [ -z "$TMUX" ] && exec tmux
# esac

case "${OSTYPE}" in
linux*)
  if [ -x /usr/bin/Xvfb ] && [ -x /usr/bin/VBoxClient ] && [ ! -f /tmp/.X0-lock ]; then
    Xvfb -screen 0 1x1x8 > /dev/null 2>&1 &!
    sleep 0.5
    DISPLAY=:0 VBoxClient --clipboard
  fi
  ;;
esac
