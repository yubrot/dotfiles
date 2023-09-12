export PATH=$HOME/AppData/Roaming/local/bin:$PATH
export PATH=$HOME/.local/bin:$PATH
export EDITOR='/c/Program Files/Neovim/bin/nvim.exe'

alias cp='cp -apr'
alias scp='scp -r'

alias ls='eza -F --group-directories-first'
alias la='ls -a'
alias s='ls --git-ignore -I "*.meta|ntuser.*|NTUSER.*|ansel|Application Data|Contacts|3D Objects|Favorites|Local Settings|OneDrive|PrintHood|Saved Games|Cookies|Links|NetHood|Recent|Searches|SendTo|Templates|Tracing|My Documents|Videos|スタート メニュー|\$Recycle.Bin|MicrosoftEdgeBackups"'
alias lss='ls -lh'
alias c='cd ..'
alias cdr='cdroot'
alias v='nvim'
alias g='git'
alias mkdir='mkdir -p'

cdroot() {
  cd `git rev-parse --show-toplevel`
}

eval "$(starship init bash)"
