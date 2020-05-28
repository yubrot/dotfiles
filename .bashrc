export PATH=$HOME/AppData/Roaming/local/bin:$PATH
export PATH=$HOME/.local/bin:$PATH
export EDITOR=/usr/bin/vim

alias cp='cp -apr'
alias scp='scp -r'
alias ls='ls -F --color=auto --group-directories-first'
alias la='ls -A'
alias s='ls -I "*.meta" -I "ntuser.*" -I "NTUSER.*" -I "Application Data" -I Contacts -I "3D Objects" -I Favorites -I "Local Settings" -I OneDrive -I PrintHood -I "Saved Games" -I Cookies -I Links -I NetHood -I Recent -I Searches -I SendTo -I Templates -I Tracing -I "My Documents" -I Videos -I "スタート メニュー" -I "\$Recycle.Bin"'
alias lss='ls -lh'
alias c='cd ..'
alias v='vim'
alias g='git'
alias mkdir='mkdir -p'

cdr() {
  cd `git rev-parse --show-toplevel`
}

