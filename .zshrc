HISTFILE=~/.histfile
HISTSIZE=1000000
SAVEHIST=1000000
bindkey -e
zstyle :compinstall filename '~/.zshrc'

case "${OSTYPE}" in
darwin*)
  export EDITOR=/Applications/MacVim.app/Contents/MacOS/Vim
  PATH=/usr/local/opt/llvm/bin:$PATH
  PATH=/Applications/MacVim.app/Contents/MacOS:$PATH
  alias vim='Vim'
  alias ls='ls -F -G' # -X
  alias cp='cp -apR'
  alias scp='scp -r'
  hash -d dl=~/Downloads
  ;;
linux*)
  export EDITOR=/usr/bin/vim
  alias ls='ls -XF --color=auto'
  alias cp='cp -apr'
  alias scp='scp -r'
  alias open='xdg-open'
  alias pbcopy='xsel --display :0 -ib'
  alias pbpaste='xsel --display :0 -ob'
  hash -d dl=~/Desktop
  ;;
msys*)
  export EDITOR=/usr/bin/vim
  alias ls='ls -XF --color=auto -I "ntuser.*" -I "NTUSER.*" -I "Application Data" -I Contacts -I Favorites -I "Local Settings" -I OneDrive -I PrintHood -I "Saved Games" -I Cookies -I Links -I NetHood -I Recent -I Searches -I SendTo -I Templates -I Tracing -I "My Documents" -I Videos -I vimperator -I "VirtualBox VMs" -I "スタート メニュー"'
  alias cp='cp -apr'
  alias scp='scp -r'
  export TMUX_TMPDIR=~/.tmux.tmp
  mkdir -p ~/.tmux.tmp
  hash -d dl=~/Downloads
  PATH=$HOME/AppData/Roaming/local/bin:$PATH
  ;;
esac

PATH=$HOME/.local/bin:$PATH
PATH=$HOME/.cargo/bin:$PATH
PATH=$HOME/.gem/bin:$PATH
PATH=$HOME/.nodebrew/current/bin:$PATH
PATH=$HOME/.yarn/bin:$PATH
export PATH

export LD_LIBRARY_PATH=/usr/local/lib:$LD_LIBRARY_PATH

export GEM_HOME=$HOME/.gem

export PATH=$HOME/Library/Android/sdk/platform-tools:$PATH
export PATH=$HOME/Library/Android/android-ndk-r10e:$PATH
export ANDROID_HOME=$HOME/Library/Android/sdk
export STUDIO_JDK=/Library/Java/JavaVirtualMachines/jdk1.8.0_31.jdk

bindkey '^f' forward-word
bindkey '^b' backward-word

autoload -Uz compinit
compinit
autoload colors
colors

setopt auto_pushd
setopt list_types
setopt pushd_ignore_dups
setopt auto_remove_slash

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
alias la='ls -A'
alias lss='ls -lh'
alias s='ls'
alias v='vim'
alias g='git'
alias d='docker'
alias dl='d ps -lq'
alias dex='d exec -it'
alias ghc='stack ghc --'
alias ghci='stack ghci --'
alias runghc='stack runghc --'
alias st='stack install --test --file-watch'
dclean() { d ps -a | grep 'weeks ago' | awk '{print $1}' | xargs --no-run-if-empty docker rm }
alias dc='docker-compose'
alias mkdir='mkdir -p'
alias zip='zip -r'
alias -g H=' | head'
alias -g T=' | tail'
alias -g G=' | grep'
alias -g L=' | less'
alias -g P=' | peco'
alias -g X=' | xargs'
alias tmongo='mongod --nojournal --noprealloc --dbpath ~/.mongo &'
alias objc='clang -fobjc-arc -fobjc-exceptions -fobjc-arc-exceptions -w -framework Foundation'
alias testserver='python -m http.server'
fignore=(.o .obj .bak .hi .deps .meta .asset .mdb .sln .unity)

hash -d box=~/Dropbox

autoload -Uz zmv
alias zmv='noglob zmv -w'

alias c='cd ..'

chpwd() {
  ls
}

cdroot() {
  cd `git rev-parse --show-toplevel`
}

htags() {
  ctags -R --languages=C --langmap=C:.h.c
  find -name \*.\*hs X hasktags -ac
  sort -o tags tags
}

cdfind() {
  local dir="$( find . -path "**/.git" -prune -o -type d | sed -e 's;\./;;' | peco )"
  if [ ! -z "$dir" ] ; then
    cd "$dir"
  fi
}

precmd() {
  print -Pn "\e]0;%n@%m %~\a %(!.#.$)"
}

extract () {
  if [ -f $1 ] ; then
      case $1 in
          *.tar.bz2)   tar xvjf $1    ;;
          *.tar.gz)    tar xvzf $1    ;;
          *.tar.xz)    tar xvJf $1    ;;
          *.bz2)       bunzip2 $1     ;;
          *.rar)       unrar x $1     ;;
          *.gz)        gunzip $1      ;;
          *.tar)       tar xvf $1     ;;
          *.tbz2)      tar xvjf $1    ;;
          *.tgz)       tar xvzf $1    ;;
          *.zip)       unzip $1       ;;
          *.Z)         uncompress $1  ;;
          *.7z)        7z x $1        ;;
          *.lzma)      lzma -dv $1    ;;
          *.xz)        xz -dv $1      ;;
          *)           echo "don't know how to extract '$1'...";;
      esac
  else
      echo "'$1' is not a valid file!"
  fi
}
alias ex='extract'

export _Z_CMD=j
source ~/.config/zsh/z.sh

source ~/.config/zsh/auto-fu.zsh
source ~/.config/zsh/auto-fu-ext.zsh

zle-line-init () { auto-fu-init; }
zle -N zle-line-init

zstyle ':auto-fu:highlight' input bold
zstyle ':auto-fu:var' postdisplay $''
zstyle ':auto-fu:var' disable magic-space
zstyle ':auto-fu:var' autoable-function/skiplbuffers \
  'yaourt *' 'pacman *' 'sudo pacman *' 'adb * *' 'g * *' \
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

. $HOME/.opam/opam-init/init.zsh > /dev/null 2> /dev/null || true
