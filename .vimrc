set nocompatible

filetype plugin indent off
set encoding=utf-8
if has('vim_starting')
  set runtimepath+=~/.vim/bundle/neobundle.vim/
endif

let s:is_darwin = stridx(system('uname'), "Darwin") != -1
let s:is_msys = stridx(system('uname'), "NT") != -1

call neobundle#begin(expand('~/.vim/bundle/'))

NeoBundleFetch 'Shougo/neobundle.vim'

NeoBundle 'Shougo/unite.vim'
NeoBundle 'Shougo/vimproc.vim', {
\ 'build' : {
\     'windows' : 'tools\\update-dll-mingw',
\     'cygwin' : 'make -f make_cygwin.mak',
\     'mac' : 'make',
\     'linux' : 'make',
\     'unix' : 'gmake',
\    },
\ }
NeoBundle 'Shougo/vimfiler.vim'

" tmp
if !s:is_msys
  NeoBundle 'Shougo/neocomplete.vim'
endif

NeoBundle 'kien/ctrlp.vim'
NeoBundle 'nathanaelkane/vim-indent-guides'
NeoBundle 'LeafCage/foldCC'
NeoBundle 'rking/ag.vim'
NeoBundle 'yanktmp.vim'
NeoBundle 'sudo.vim'
NeoBundle 'tpope/vim-surround'
NeoBundle 'thinca/vim-quickrun'
NeoBundle 'thinca/vim-visualstar'
NeoBundle 'glidenote/memolist.vim'
NeoBundle 'sjl/gundo.vim'
NeoBundle 'kana/vim-operator-replace'
NeoBundle 'kana/vim-operator-user'
NeoBundle 'LeafCage/yankround.vim'
NeoBundle 'kana/vim-submode'
NeoBundle 'bling/vim-airline'
NeoBundle 'gitignore'
NeoBundle 'tyru/caw.vim'

NeoBundle 'w0ng/vim-hybrid'

NeoBundle 'tpope/vim-fugitive'
NeoBundle 'gregsexton/gitv'
NeoBundle 'jreybert/vimagit'

NeoBundle 'eagletmt/ghcmod-vim'
NeoBundle 'eagletmt/neco-ghc'
NeoBundle 'mattn/emmet-vim'
NeoBundle 'leafgarland/typescript-vim'
NeoBundle 'rust-lang/rust.vim'
NeoBundle 'cespare/vim-toml'
NeoBundle 'elixir-lang/vim-elixir'
NeoBundle 'lambdatoast/elm.vim'
NeoBundle 'digitaltoad/vim-jade'
"NeoBundle 'slimv.vim'
NeoBundle 'rhysd/vim-llvm'
NeoBundle 'rhysd/vim-crystal'
NeoBundle 'udalov/kotlin-vim'
NeoBundle 'derekwyatt/vim-scala'
NeoBundle 'keith/swift.vim'
if s:is_darwin
  NeoBundleLazy 'OmniSharp/omnisharp-vim', {
    \   'autoload': { 'filetypes': [ 'cs', 'csi', 'csx' ] },
    \   'build': {
    \     'windows' : 'msbuild server/OmniSharp.sln',
    \     'mac': 'xbuild server/OmniSharp.sln',
    \     'unix': 'xbuild server/OmniSharp.sln',
    \   },
    \ }
endif
NeoBundleLazy 'alpaca-tc/beautify.vim', {
  \ 'autoload' : {
  \   'commands' : [
  \     {
  \       'name' : 'Beautify',
  \       'complete' : 'customlist,beautify#complete_options'
  \     }
  \ ]
  \ }}

call neobundle#end()

filetype plugin indent on
NeoBundleCheck

set number
set noswapfile
set noundofile

set wildmenu
set showcmd
set hlsearch
set incsearch

set tags=tags;

set t_Co=256
syntax enable

"let g:hybrid_use_iTerm_colors = 1
set background=dark
colorscheme hybrid

set nowrap

set hidden

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

set t_vb=
set novisualbell

set notimeout
set nobackup

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
  w
endfunction
command W :call ToUNI()
command Xe :%!xxd
command Xd :%!xxd -r

nnoremap s <Nop>
nnoremap Q <Nop>
nnoremap <Esc><Esc> :nohl<CR>
autocmd FileType haskell nnoremap <buffer> <Esc><Esc> :nohl<CR>:GhcModTypeClear<CR><Esc>

nnoremap [org] <Nop>
map <Space> [org]

nnoremap [org]t :tabnew<CR>
nnoremap [org]s :tab split<CR>
nnoremap [org]d :q<CR>
nnoremap [org]D :bd<CR>
nnoremap H gT
nnoremap L gt

function! ModifiedCheck()
  if &mod == 1
    tab split
  endif
endfunction

nnoremap [org]f :call ModifiedCheck()<CR>:VimFiler<CR>
nnoremap [org]o :call ModifiedCheck()<CR>:CtrlP<CR>
nnoremap [org]a :call ModifiedCheck()<CR>:Ag 

"nnoremap [org]b :CtrlPBuffer<CR>
"nnoremap H :bp<CR>
"nnoremap L :bn<CR>

"nnoremap [org]w :setl wrap!<CR>
nnoremap [org]w :w<CR>

nnoremap ss :<C-u>sp<CR>
nnoremap sv :<C-u>vs<CR>

nnoremap sh <C-w>h
nnoremap sj <C-w>j
nnoremap sk <C-w>k
nnoremap sl <C-w>l
nnoremap [org]n <C-w><C-w>

nnoremap sH <C-w>H
nnoremap sJ <C-w>J
nnoremap sK <C-w>K
nnoremap sL <C-w>L

nnoremap so <C-w>_<C-w>|
nnoremap sO <C-w>=
call submode#enter_with('bufmove', 'n', '', 's>', '<C-w>>')
call submode#enter_with('bufmove', 'n', '', 's<', '<C-w><')
call submode#enter_with('bufmove', 'n', '', 's+', '<C-w>+')
call submode#enter_with('bufmove', 'n', '', 's-', '<C-w>-')
call submode#map('bufmove', 'n', '', '>', '<C-w>>')
call submode#map('bufmove', 'n', '', '<', '<C-w><')
call submode#map('bufmove', 'n', '', '+', '<C-w>+')
call submode#map('bufmove', 'n', '', '-', '<C-w>-')

vnoremap sf zf
nnoremap so zo
nnoremap sc zc
nnoremap sO zO
nnoremap sC zC

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
let g:airline#extensions#tabline#fnamemod = ':t'

nnoremap [org]gs :Gstatus<CR>
nnoremap [org]gl :Gitv<CR>
nnoremap [org]gf :Gitv!<CR>

if s:is_darwin
  set ambiwidth=double
  let g:previm_open_cmd = 'open -a Firefox'
endif

if s:is_darwin
  vnoremap <silent> [org]y :w !pbcopy<CR><CR>
  nnoremap <silent> [org]p :r !pbpaste<CR>
elseif s:is_msys
  vnoremap <silent> [org]y :w !cat >/dev/clipboard<CR><CR>
  nnoremap <silent> [org]p :r !cat /dev/clipboard<CR>
else
  vnoremap <silent> [org]y :w !xsel --display :0 -ib<CR><CR>
  nnoremap <silent> [org]p :r !xsel --display :0 -ob<CR>
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

nnoremap \gt :GhcModType<CR>
nnoremap \gi :GhcModTypeInsert<CR>
nnoremap \gc :GhcModCheckAndLintAsync<CR>

let g:necoghc_enable_detailed_browse=1
"autocmd FileType haskell setlocal iskeyword=a-z,A-Z,_,.,39

nnoremap \c :make %<CR>
let b:quickrun_config = {'outputter/buffer/split': "", 'outputter/buffer/into': 1}
let g:quickrun_config = {}
let g:quickrun_config['jade'] = {'command': 'jade', 'cmdopt': '-P', 'exec': ['%c &o < %s']}
let g:quickrun_config['haxe'] = {'command': 'haxe', 'args': '-x', 'cmdopt': '-main '."%{HaxeClssName(expand(\"%S:t:r\"))}", 'exec' : "%c %o %a %s:p"}
let g:quickrun_config['swift'] = {'command': 'swift', 'exec': '%c %o %s'}
let g:quickrun_config['haskell'] = {'command': 'stack', 'cmdopt': 'runghc --', 'exec': '%c %o %s'}

function! HaxeClssName(word)
  return substitute(a:word, '^\v.*\ze\.hx', '\u&', '')
endfunction

"autocmd BufWritePost *.coffee silent make!
"autocmd BufWritePost *.ts make
autocmd QuickFixCmdPost [^l]* nested cwindow

let g:ctrlp_custom_ignore = {
  \ 'dir': '\.\(hg\|git\|sass-cache\|svn\)$\|__\|bower_components\|node_modules\|build-ios',
  \ 'file': '\.\(meta\|dll\|exe\|gif\|jpg\|png\|psd\|so\|woff\|o\|obj\|lib\|o\.d\|ap_\|apk\|class\|ap_\.d\|apk\.d\)$' }
let g:ctrlp_by_filename = 1
let g:ctrlp_switch_buffer = 'Et'
let g:ctrlp_map = '<Nop>'

let g:ctrlp_use_caching = 0
if executable('ag')
    set grepprg=ag\ --nogroup\ --nocolor

    let g:ctrlp_user_command = 'ag %s -l --nocolor -g ""'
else
  let g:ctrlp_user_command = ['.git', 'cd %s && git ls-files . -co --exclude-standard', 'find %s -type f']
  let g:ctrlp_prompt_mappings = {
    \ 'AcceptSelection("e")': ['<space>', '<cr>', '<2-LeftMouse>'],
    \ }
endif

let g:indent_guides_enable_on_vim_startup = 1
let g:indent_guides_auto_colors=0
hi IndentGuidesOdd ctermbg=235

set shiftwidth=2 softtabstop=2
autocmd FileType cs setlocal shiftwidth=4 softtabstop=4
autocmd FileType swift setlocal shiftwidth=2 softtabstop=2
autocmd FileType objc setlocal shiftwidth=4 softtabstop=4
autocmd FileType java setlocal shiftwidth=4 softtabstop=4
autocmd FileType groovy setlocal shiftwidth=4 softtabstop=4
autocmd FileType kotlin setlocal shiftwidth=4 softtabstop=4

let g:ag_apply_qmappings=0
let g:ag_apply_lmappings=0

let g:paredit_shortmaps = 1
au BufNewFile,BufRead *.purs setf haskell
au BufNewFile,BufRead Guardfile set filetype=ruby
au BufNewFile,BufRead *.gradle set filetype=groovy

if !s:is_msys
  let g:neocomplete#enable_at_startup = 1
  let g:neocomplete#enable_smart_case = 1
  let g:neocomplete#sources#syntax#min_keyword_length = 3
  let g:neocomplete#lock_buffer_name_pattern = '\*ku\*'

  " Define dictionary.
  let g:neocomplete#sources#dictionary#dictionaries = {
      \ 'default' : '',
      \ 'vimshell' : $HOME.'/.vimshell_hist',
      \ 'scheme' : $HOME.'/.gosh_completions'
          \ }

  if !exists('g:neocomplete#keyword_patterns')
      let g:neocomplete#keyword_patterns = {}
  endif
  let g:neocomplete#keyword_patterns['default'] = '\h\w*'

  inoremap <silent> <CR> <C-r>=<SID>my_cr_function()<CR>
  function! s:my_cr_function()
    return neocomplete#smart_close_popup() . "\<CR>"
  endfunction

  imap <expr><TAB> pumvisible() ? "\<C-n>" : "\<TAB>"

  inoremap <expr><BS> neocomplete#smart_close_popup()."\<C-h>"
  inoremap <expr><C-e> neocomplete#cancel_popup()

  " Enable omni completion.
  autocmd FileType css setlocal omnifunc=csscomplete#CompleteCSS
  autocmd FileType html,markdown setlocal omnifunc=htmlcomplete#CompleteTags
  autocmd FileType javascript setlocal omnifunc=javascriptcomplete#CompleteJS
  autocmd FileType python setlocal omnifunc=pythoncomplete#Complete
  autocmd FileType xml setlocal omnifunc=xmlcomplete#CompleteTags

  " Enable heavy omni completion.
  if !exists('g:neocomplete#sources#omni#input_patterns')
    let g:neocomplete#sources#omni#input_patterns = {}
  endif

  let g:neocomplete#sources#omni#input_patterns.cs = '.*[^=\);]'

  if s:is_darwin
    autocmd FileType cs setlocal omnifunc=OmniSharp#Complete
  endif

  let g:haskellmode_completion_ghc = 0
  autocmd FileType haskell setlocal omnifunc=necoghc#omnifunc
endif

if has('conceal')
  set conceallevel=2 concealcursor=i
endif

