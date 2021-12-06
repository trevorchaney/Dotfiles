"               Trevor's configuration file for Vim on Windows.

"=____=======_===_===_===================
"/ ___|  ___| |_| |_(_)_ __   __ _ ___  |
"\___ \ / _ \ __| __| | '_ \ / _` / __| |
" ___) |  __/ |_| |_| | | | | (_| \__ \ |
"|____/ \___|\__|\__|_|_| |_|\__, |___/ |
"                            |___/      |
"========================================

" Set vim colors.
syntax enable
"set background=dark
"colorscheme solarized

" Vim with all enhancements
source $VIMRUNTIME/vimrc_example.vim

"" Enable transparency set by emulator. Must be after colorscheme.
"hi Normal guibg=NONE ctermbg=NONE

" Set vim behavior.
set modelines=0         " CVE-2007-2438
set nocompatible        " Use Vim defaults instead of 100% vi compatibility
set backspace=2         " More powerful backspacing
set nu                  " Enable line numbers at startup.
set printoptions=number:y   " Adds numbers to :hardcopy command.
set undofile            " Maintain undo history between sessions.
set undodir=C:\tools\vim\undodir  " Directory to vim undo files.
set spelllang=en_us     "
set complete+=kspell    "
set mouse=a             " Enable mouse support for gui and term with support.
set incsearch           " Incremental search.
set hlsearch            " Highlight search.
set ignorecase          " Ignore case in searches.
set smartcase           " '' excepted if an uppercase letter is used.
set history=500         " Sets how many lines of history VIM has to remember.
set hidden              " Allow buffer switching without saving.
set colorcolumn=80      " Add a colored column at 80.
set path+=**            " Used for nested file searching.
set wildmenu            " Show tab completion options.
set listchars=tab:o-,nbsp:_,trail:- " Exposes whitespace characters.
set list                " This and the above expose whitespace characters.
set foldmethod=indent   " Allows indented code folding.
set foldnestmax=10      "
set nofoldenable        "
set nrformats+=alpha    " Make letters increment and decrement able.
set foldlevel=2         "
set tabstop=4           "      " [] Add context to these.
set softtabstop=4       "
set shiftwidth=4        "
set autowrite           "
set updatetime=300      " Faster refresh rate.
set autoindent          "
set expandtab           "
set tags+=/usr/local/include/tags "
set cursorline
"set errorformat^=%-GIn\ file\ included\ %.%#   " General ignore format
set errorformat^=%+Gmake%.%#    " Remove makefile errors from error jump list.
hi CursorLine term=NONE cterm=None ctermbg=black
hi CursorLine term=NONE cterm=None ctermbg=0
hi Pmenu ctermfg=15 ctermbg=236 guibg=Magenta
au WinEnter * setlocal cursorline
au WinLeave * setlocal nocursorline

" Don't write backup file if vim is being called by "crontab -e"
au BufWrite /private/tmp/crontab.* set nowritebackup nobackup

" Don't write backup file if vim is being called by "chpass"
au BufWrite /private/etc/pw.* set nowritebackup nobackup

" Set proper indentation for html, css, & javascript.
autocmd FileType html,css,javascript setlocal tabstop=2 softtabstop=2 shiftwidth=2

" Set syntax highlighting for misc. c++ file extentions.
autocmd BufEnter *.tpp :setlocal filetype=cpp

" Set proper tab character for make.
autocmd FileType make setlocal noexpandtab

"=__==__===================_===================
"|  \/  | __ _ _ __  _ __ (_)_ __   __ _ ___  |
"| |\/| |/ _` | '_ \| '_ \| | '_ \ / _` / __| |
"| |  | | (_| | |_) | |_) | | | | | (_| \__ \ |
"|_|  |_|\__,_| .__/| .__/|_|_| |_|\__, |___/ |
"             |_|   |_|            |___/      |
"==============================================
" Set <leader> to <space>.
let mapleader=" "
" (n)ormal-mode (no)n-(re)cursive (map).
" Remove search highlighting till next search.
nnoremap <silent> <leader><esc> :noh<cr>
" Build tags.
nnoremap <silent> <leader>t :!ctags &<cr>
" Compile latex (.tex) documents from normal mode.
nnoremap <silent> <leader>l :w<cr>:!pdflatex %; open %:t:r.pdf<cr>
" Brace completion.
"inoremap {<cr> {<cr>}<esc>O<tab>       " Replaced with Auto-Pairs plugin
inoremap {<cr> {<cr>}<esc>O
" Paren completion.
"inoremap (<cr> (<cr>)<esc>O<tab>       " Replaced with Auto-Pairs plugin
inoremap (<cr> (<cr>)<esc>O
" Move to next fill character, staying in insert mode and removing highlight.
inoremap <C-h> <esc>/<##><cr>:noh<cr>"_c4l
" Trigger Codi scratchpad.
nnoremap <silent> <leader>c :Codi!!<cr>
" Increment a number.
"nnoremap <C-k> <C-a>           " Remapping interferes with COC.nvim.
" Decrement a number.
"nnoremap <C-j> <C-x>           " Remapping interferes with COC.nvim.
" Place fill character.
nmap <C-h> i<##><esc>
" Move to next fill character, stay in insert mode, and remove highlight.
inoremap <C-h> <esc>/<##><cr>:noh<cr>"_c4l
" Line break at cursor.
nmap <silent> <leader><leader> i<cr><esc>
" Place blank line below. (stays in normal mode)
nmap <silent> <leader>o o<esc>
" Place blank line above. (stays in normal mode)
nmap <silent> <leader>O O<esc>
" Open and close project drawer, use :Lexplore if there is no NERDTree.
"nmap <silent> <leader><tab> :Lexplore<CR>
nmap <silent> <leader><tab> :NERDTreeToggle<CR>
"cnoremap w<cr> w<cr>:!ctags<cr>    " Replaced with Plugin 'vim-autotag'
"nnoremap <leader>9 bcw()<esc>P
" List available buffers
nnoremap <silent> <leader>b :ls<cr>:b<space>
" Make the current file into a pdf.
nnoremap <silent> <leader>p :w<cr>:ha>%.ps<cr>:!ps2pdf %.ps && rm %.ps<cr>
" Autocorrect next misspelled word.
nnoremap <silent> <leader>z ]s1z=

" Close all but the current buffer.
command CloseAllButCurrent silent! execute "%bd|e#|bd#"
nnoremap <silent> <leader>d :CloseAllButCurrent<cr>
nnoremap <silent> <leader>4 :Files<cr>

"==__==================_===_===================
" / _|_   _ _ __   ___| |_(_) ___  _ __  ___  |
"| |_| | | | '_ \ / __| __| |/ _ \| '_ \/ __| |
"|  _| |_| | | | | (__| |_| | (_) | | | \__ \ |
"|_|  \__,_|_| |_|\___|\__|_|\___/|_| |_|___/ |
"==============================================
" Sets <leader>n to toggle between absolute, relative,
" and no line numbers.
function! g:ToggleNuMode()
    if(&rnu == 1 && &nu == 1)
        set nornu
        set nonu
    elseif(&nu == 0)
        set nu
    else
        set rnu
    endif
endfunc
nnoremap <silent> <leader>n :call g:ToggleNuMode()<cr>

" Sets <leader>s to toggle spelling markup.
function! g:ToggleSpellMode()
    if(&spell == 1)
        set nospell
    else
        set spell
    endif
endfunc
nnoremap <silent> <leader>s :call g:ToggleSpellMode()<cr>

" Allows for running macros over all visually selected lines with @.
function! ExecuteMacroOverVisualRange()
    echo "@".getcmdline()
    execute ":'<, '>normal @".nr2char(getchar())
endfunc
xnoremap @ :<C-u>call ExecuteMacroOverVisualRange()<CR>

" Use the internal diff if available.
" Otherwise use the special 'diffexpr' for Windows.
if &diffopt !~# 'internal'
  set diffexpr=MyDiff()
endif
function MyDiff()
  let opt = '-a --binary '
  if &diffopt =~ 'icase' | let opt = opt . '-i ' | endif
  if &diffopt =~ 'iwhite' | let opt = opt . '-b ' | endif
  let arg1 = v:fname_in
  if arg1 =~ ' ' | let arg1 = '"' . arg1 . '"' | endif
  let arg1 = substitute(arg1, '!', '\!', 'g')
  let arg2 = v:fname_new
  if arg2 =~ ' ' | let arg2 = '"' . arg2 . '"' | endif
  let arg2 = substitute(arg2, '!', '\!', 'g')
  let arg3 = v:fname_out
  if arg3 =~ ' ' | let arg3 = '"' . arg3 . '"' | endif
  let arg3 = substitute(arg3, '!', '\!', 'g')
  if $VIMRUNTIME =~ ' '
    if &sh =~ '\<cmd'
      if empty(&shellxquote)
        let l:shxq_sav = ''
        set shellxquote&
      endif
      let cmd = '"' . $VIMRUNTIME . '\diff"'
    else
      let cmd = substitute($VIMRUNTIME, ' ', '" ', '') . '\diff"'
    endif
  else
    let cmd = $VIMRUNTIME . '\diff'
  endif
  let cmd = substitute(cmd, '!', '\!', 'g')
  silent execute '!' . cmd . ' ' . opt . arg1 . ' ' . arg2 . ' > ' . arg3
  if exists('l:shxq_sav')
    let &shellxquote=l:shxq_sav
  endif
endfunction
