set nocompatible
set ruler
syn on
set hls " highlight search
set is  " Instant search
set guifont=MonoSpace\ 10
set showmatch
set matchtime=3
set statusline=%<%f%m%r%y%=%b\ 0x%B\ \ %l,%c%V\ %P
set laststatus=2  " always a status line
set ofu=syntaxcomplete#Complete

"nmap <C-i> :set hls<return>
"nmap <S-i> :set nohls<return>

" Makfiles python... (scons)
au BufNewFile,BufRead SConstruct,SConscript,*.rpy set filetype=python
au BufNewFile,BufRead CMakeLists.txt set filetype=cmake
au BufNewFile,BufRead *.aiml set filetype=xml
au BufNewFile,BufRead *.pxi set filetype=pyrex
au BufNewFile,BufRead *.io set filetype=io
au BufNewFile,BufRead hgrc,.hgrc set filetype=cfg
au BufNewFile,BufRead *sylpheed*tmp* set filetype=mail
au BufNewFile,BufRead *.py set omnifunc=pythoncomplete#Complete

filetype plugin indent on

set encoding=utf-8
set fileencodings=utf-8,iso8859-1
set smartcase
set showcmd
set ts=4 sw=4 noet
set wmh=0
"set bs=2

" remove insert mapings
" imapclear

" foldmethod :
"set fdm=indent foldlevel=5
set fdm=manual

" vimspell
let spell_executable = "hunspell"
let spell_insert_mode = 0
let spell_guess_language_ft = ""
let spell_language_list = "fr,en"

" menus + tags
set grepprg=grep\ -nH\ $*
" uses spaces :(
set et

