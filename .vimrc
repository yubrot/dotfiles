if &compatible
  set nocompatible
endif

let s:is_darwin = stridx(system('uname'), "Darwin") != -1
let s:is_msys = stridx(system('uname'), "NT") != -1

let s:dein_dir = expand('~/.cache/dein')
let s:dein_repo_dir = s:dein_dir . '/repos/github.com/Shougo/dein.vim'

if &runtimepath !~# '/dein.vim'
  if !isdirectory(s:dein_repo_dir)
    execute '!git clone https://github.com/Shougo/dein.vim' s:dein_repo_dir
  endif
  execute 'set runtimepath+=' . fnamemodify(s:dein_repo_dir, ':p')
endif

if dein#load_state(s:dein_dir)
  call dein#begin(s:dein_dir)

  call dein#add('Shougo/dein.vim')

  " temporary
  call dein#add('Shougo/vimproc.vim', {'build' : 'make'})
  call dein#add('Shougo/unite.vim')
  call dein#add('Shougo/vimfiler.vim')

  " core
  call dein#add('w0ng/vim-hybrid')
  call dein#add('ctrlpvim/ctrlp.vim')
  call dein#add('nathanaelkane/vim-indent-guides')
  call dein#add('LeafCage/foldCC')
  call dein#add('rking/ag.vim')
  call dein#add('vim-scripts/yanktmp.vim')
  call dein#add('vim-scripts/sudo.vim')
  call dein#add('tpope/vim-surround')
  call dein#add('thinca/vim-quickrun')
  call dein#add('thinca/vim-visualstar')
  call dein#add('glidenote/memolist.vim')
  call dein#add('sjl/gundo.vim')
  call dein#add('kana/vim-operator-replace')
  call dein#add('kana/vim-operator-user')
  call dein#add('kana/vim-smartchr')
  call dein#add('LeafCage/yankround.vim')
  call dein#add('bling/vim-airline')
  call dein#add('tyru/caw.vim')
  call dein#add('tpope/vim-fugitive')
  call dein#add('octref/RootIgnore')
  call dein#add('gregsexton/gitv')
  call dein#add('jreybert/vimagit')

  " language support
  call dein#add('leafgarland/typescript-vim')
  call dein#add('rust-lang/rust.vim')
  call dein#add('cespare/vim-toml')
  call dein#add('rhysd/vim-llvm')
  call dein#add('derekwyatt/vim-scala')
  call dein#add('idris-hackers/idris-vim')

  call dein#end()
  call dein#save_state()
endif

if dein#check_install()
  call dein#install()
endif

filetype plugin indent on
syntax enable

set encoding=utf-8

set background=dark
colorscheme hybrid

set number

set hidden
set nobackup
set noswapfile
set noundofile

set wildmenu
set showcmd
set hlsearch
set incsearch

set tags=tags;

set t_Co=256

set nowrap
set backspace=indent,eol,start

set expandtab
set tabstop=4
set smarttab
set shiftround

set list
set listchars=tab:>-,trail:_

set ignorecase
set smartcase
set autoindent
set smartindent

set ruler
set laststatus=2
set cmdheight=1

set ambiwidth=double

set t_vb=
set novisualbell

set notimeout

set scrolloff=6

set cursorline

set completeopt=menuone

set foldmethod=marker
set foldtext=FoldCCtext()

let g:html_use_css = 1

runtime macros/matchit.vim

command E :e ++enc=euc-jp
command S :e ++enc=shift_jis
command U :e ++enc=utf-8
command SU :e sudo:%
function! ToDOS()
  set fileformat=dos
  set fenc=utf-8 bomb
endfunction
command DOS :call ToDOS()
function! ToUNI()
  set ff=unix
  set fenc=utf8
endfunction
command W :call ToUNI()
command Xe :%!xxd
command Xd :%!xxd -r
command JSON :%!python -m json.tool

nnoremap s <Nop>
nnoremap Q <Nop>
nnoremap <Esc><Esc> :nohl<CR>

nnoremap [org] <Nop>
map <Space> [org]

nnoremap [org]t :tabnew<CR>
nnoremap [org]s :tab split<CR>
nnoremap [org]d :call ModifiedCheck()<CR>:q<CR>
nnoremap [org]D :bd<CR>
nnoremap [org]n <C-w>w
nnoremap H gT
nnoremap L gt

nnoremap [org]f :call ModifiedCheck()<CR>:VimFiler<CR>
nnoremap [org]o :call ModifiedCheck()<CR>:CtrlP<CR>
nnoremap [org]a :call ModifiedCheck()<CR>:Ag 
nnoremap [org]w :w<CR>

function! ModifiedCheck()
  if &mod == 1
    tab split
  endif
endfunction

nnoremap [org]mo :exe "CtrlP" g:memolist_path<CR><F5>
nnoremap [org]mn :MemoNew<CR>
nnoremap [org]mg :MemoGrep<CR>
nnoremap [org]md :MemoList<CR>
let g:memolist_path = "~/util"
let g:memolist_filename_prefix_none = 1
let g:memolist_vimfiler = 1
let g:memolist_memo_suffix = "mkd"

let g:yankround_max_history = 100
nmap p <Plug>(yankround-p)
nmap P <Plug>(yankround-P)
nmap gp <Plug>(yankround-gp)
nmap gP <Plug>(yankround-gP)
nmap <C-p> <Plug>(yankround-prev)
nmap <C-n> <Plug>(yankround-next)

nmap _ <Plug>(operator-replace)

nnoremap [org]u :GundoToggle<CR>
map * <Plug>(visualstar-*)N
nnoremap <expr> gp '`[' . strpart(getregtype(), 0, 1) . '`]'
vmap / <Plug>(caw:i:toggle)

nnoremap <C-]> :call ModifiedCheck()<CR><C-]>
nnoremap <C-b> <C-t>
nnoremap tn :tn<CR>
nnoremap tp :tp<CR>
nnoremap tl <C-w>}
nnoremap th <C-w><C-z>

let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#show_buffers = 0
let g:airline#extensions#tabline#show_tab_type = 0
let g:airline#extensions#tabline#formatter = 'unique_tail'

nnoremap [org]gs :Gstatus<CR>
nnoremap [org]gl :Gitv<CR>
nnoremap [org]gf :Gitv!<CR>

if s:is_darwin
  vnoremap <silent> [org]y :w !pbcopy<CR><CR>
elseif s:is_msys
  vnoremap <silent> [org]y :w !cat >/dev/clipboard<CR><CR>
else
  vnoremap <silent> [org]y :w !clip.exe<CR><CR>
endif

set pastetoggle=<F11>
map <silent> sy :call YanktmpYank()<CR>
map <silent> sp :call YanktmpPaste_p()<CR>
map <silent> sP :call YanktmpPaste_P()<CR>

noremap [org]h ^
noremap [org]l $
noremap [org]j 10j
noremap [org]k 10k

nnoremap to `
nnoremap n nzz
nnoremap N Nzz
nnoremap j gj
nnoremap k gk
vnoremap j gj
vnoremap k gk

vnoremap v $h
nnoremap <Tab> %
vnoremap <Tab> %

nnoremap Y y$

nnoremap + <C-a>
nnoremap - <C-x>

nnoremap \c :make %<CR>
let b:quickrun_config = {'outputter/buffer/split': "", 'outputter/buffer/into': 1}
let g:quickrun_config = {}
let g:quickrun_config['swift'] = {'command': 'swift', 'exec': '%c %o %s'}

autocmd QuickFixCmdPost [^l]* nested cwindow

let g:ctrlp_custom_ignore = {
  \ 'dir': '\.\(hg\|git\|sass-cache\|svn\)$\|__\|bower_components\|node_modules\|build-ios',
  \ 'file': '\.\(meta\|dll\|exe\|gif\|jpg\|png\|psd\|so\|woff\|o\|obj\|lib\|o\.d\|ap_\|apk\|class\|ap_\.d\|apk\.d\)$' }
let g:ctrlp_by_filename = 1
let g:ctrlp_switch_buffer = 'Et'
let g:ctrlp_map = '<Nop>'

let g:ctrlp_use_caching = 0
let g:ctrlp_user_command = ['.git', 'cd %s && git ls-files . -co --exclude-standard', 'find %s -type f']
let g:ctrlp_prompt_mappings = {
  \ 'AcceptSelection("e")': ['<space>', '<cr>', '<2-LeftMouse>'],
  \ }

let g:indent_guides_enable_on_vim_startup = 1
let g:indent_guides_auto_colors=0
hi IndentGuidesOdd ctermbg=235

set shiftwidth=2 softtabstop=2
autocmd FileType cs,java,objc,groovy,kotlin,swift setlocal shiftwidth=4 softtabstop=4
autocmd FileType go,make setlocal noexpandtab shiftwidth=4 listchars=tab:\ \ ,trail:_

autocmd FileType lisp setlocal lispwords+=let1,def,defrecord,fun,for,let/cc,shift

if executable('opam')
  let g:opamshare = substitute(system('opam config var share'),'\n$','','''')
  execute "set rtp+=" . g:opamshare . "/merlin/vim"
  execute "set rtp^=" . g:opamshare . "/ocp-indent/vim"
endif

let g:ag_apply_qmappings=0
let g:ag_apply_lmappings=0

let g:paredit_shortmaps = 1
au BufNewFile,BufRead *.purs setf haskell
au BufNewFile,BufRead Guardfile set filetype=ruby
au BufNewFile,BufRead *.gradle set filetype=groovy

autocmd FileType javascript,typescript inoremap <buffer><expr> @ smartchr#one_of('this.', '@')

