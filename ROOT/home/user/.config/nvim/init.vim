set nocompatible               " Be iMproved
"set ofu=syntaxcomplete#Complete
filetype plugin indent on
syntax enable

call plug#begin('~/.config/nvim/addons')
Plug 'junegunn/vim-easy-align'
Plug 'neomake/neomake'
Plug 'hrp/EnhancedCommentify'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'vim-scripts/Align'
" completers
Plug 'davidhalter/jedi-vim'
Plug 'scrooloose/nerdtree'
Plug 'dhruvasagar/vim-table-mode'
"Plug  'Valloric/YouCompleteMe'
"Plug 'Shougo/deoplete.nvim'
"Plug 'zchee/deoplete-jedi'
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'sheerun/vim-polyglot'
call plug#end()

let g:ale_lint_on_text_changed = 'never'

let mapleader = "²"

set background=dark
set ruler
syn on
set hls " highlight search
set is  " Instant search
set guifont=Hack\ 10
set showmatch
set matchtime=3
set statusline=%<%f%m%r%y%=%b\ 0x%B\ \ %l,%c%V\ %P
set laststatus=2  " always a status line
:hi Search cterm=NONE ctermfg=black ctermbg=grey

au Filetype html,xml,xsl source ~/.vim/scripts/closetag.vim
au BufNewFile,BufRead *sylpheed*tmp* set filetype=mail
au BufNewFile,BufRead *.rst set spell spelllang=en_us
    
map <C-c> :call EnhancedCommentify('yes','guess')<CR>j
map <M-s> :mksession! ~/vimsession

map <M-c> :Neomake<CR>
map <leader>t :TableModeToggle<CR>
map <leader>o :FZF<CR>

if(argc() == 0)
  au VimEnter * nested :source ~/vimsession
endif

set encoding=utf-8
set fileencodings=utf-8,iso8859-1
set smartcase
set showcmd

set ts=4 sw=4 noet
set wmh=0
set fdm=manual
set grepprg=grep\ -nH\ $*
let python_highlight_all = 1
set et
let g:pymode_folding = 0

let g:airline_theme='badwolf' " cool is nice too
let g:airline_symbols_ascii=1
let g:airline_powerline_fonts = 0

set mouse=c

"set statusline+=%#warningmsg#
"set statusline+=%{SyntasticStatuslineFlag()}
"set statusline+=%*

let g:table_mode_corner_corner='+'
let g:table_mode_header_fillchar='='
