HISTFILE=~/.histfile
HISTSIZE=1000000
SAVEHIST=1000000

bindkey -e
zstyle :compinstall filename '~/.zshrc'

case "${OSTYPE}" in
darwin*)
  alias cp='cp -apR'
  export EDITOR=/opt/homebrew/bin/nvim
  export PATH=/opt/homebrew/bin:$PATH
  ;;
linux*)
  alias cp='cp -apr'
  export EDITOR=/usr/bin/nvim
  export DISPLAY=$(cat /etc/resolv.conf | grep nameserver | awk '{print $2}'):0
  ;;
esac

alias scp='scp -r'
alias c='cd ..'
alias cdr='cdroot'
alias ls='eza -F --group-directories-first'
alias la='ls -a'
alias s='ls --git-ignore -I "*.meta"'
alias v='nvim'
alias g='git'
alias lss='ls -lh'
alias mkdir='mkdir -p'
alias zip='zip -r'
alias -g G=' | grep'


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

# Rust
export PATH=$HOME/.cargo/bin:$PATH
export LLVMENV_RUST_BINDING=1

# Node
export PATH=$HOME/.nodebrew/current/bin:$PATH

# .NET
export DOTNET_SKIP_FIRST_TIME_EXPERIENCE=true
export DOTNET_CLI_UI_LANGUAGE=en-us
export PATH=$HOME/.dotnet/tools:$PATH
alias dot='TERM=xterm dotnet'

# Java
export PATH="$HOME/.jenv/bin:$PATH"

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

ZSH_AUTOSUGGEST_STRATEGY=(completion)
ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20
ZSH_AUTOSUGGEST_USE_ASYNC=true
[ -d /opt/homebrew/share/zsh-autosuggestions ] && source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh
[ -d /usr/share/zsh/plugins/zsh-autosuggestions ] && source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
# workaround https://github.com/zsh-users/zsh-autosuggestions/issues/512
_zsh_autosuggest_capture_postcompletion() {
  unset 'compstate[list]'
}

[ -f "${GHCUP_INSTALL_BASE_PREFIX:=$HOME}/.ghcup/env" ] && source "${GHCUP_INSTALL_BASE_PREFIX:=$HOME}/.ghcup/env"
command -v llvmenv >/dev/null 2>&1 && source <(llvmenv zsh)
command -v goenv >/dev/null 2>&1 && eval "$(goenv init -)"
command -v jenv >/dev/null 2>&1 && eval "$(jenv init -)"
command -v rbenv >/dev/null 2>&1 && eval "$(rbenv init - zsh)"

eval "$(starship init zsh)"
eval "$(direnv hook zsh)"

