" Configuration file for vim
"===================================
"   ___                       _    |
"  / __|___ _ _  ___ _ _ __ _| |   |
" | (_ / -_) ' \/ -_) '_/ _` | |   |
"  \___\___|_||_\___|_| \__,_|_|   |
"                                  l
"===================================
" _____Mappings_____
" Set <leader> to <space>.
let mapleader=" "
" (n)ormal-mode (no)n-(re)cursive (map).
" Remove search highlighting till next search.
nnoremap <silent> <leader><esc> :noh<cr>
" Build tags.
nnoremap <silent> <leader>t :!ctags<cr>
" Compile latex (.tex) documents from normal mode.
nnoremap <silent> <leader>l :w<cr>:!pdflatex %; open %:t:r.pdf<cr>
" Brace completion.
inoremap {<cr> {<cr>}<esc>O
" Move to next fill character, staying in insert mode and removing highlight.
inoremap <C-h> <esc>/<##><cr>:noh<cr>"_c4l
" Increment a number.
nnoremap <C-k> <C-A>
" Decrement a number.
nnoremap <C-j> <C-X>
" Place fill character.
nmap <C-h> i<##><esc>
" Line break at cursor.
nmap <silent> <leader><leader> i<cr><esc>
" Place blank line below. (stays in normal mode)
nmap <silent> <leader>o o<esc>
" Place blank line above. (stays in normal mode)
nmap <silent> <leader>O O<esc>
" Open and close project drawer.
nmap <silent> <leader><tab> :NERDTreeToggle<CR>
"cnoremap w<cr> w<cr>:!ctags<cr>    " Replaced with Plugin 'vim-autotag'
"nnoremap <leader>9 bcw()<esc>P
"
" Set vim colors.
syntax enable
set background=dark
colorscheme solarized
"
" Enable transparency set by emulator. Must be after colorscheme.
hi Normal guibg=NONE ctermbg=NONE
"
" Set vim behavior.
set modelines=0         " CVE-2007-2438
set nocompatible        " Use Vim defaults instead of 100% vi compatibility
set backspace=2         " More powerful backspacing
set nu                  " Enable line numbers at startup.
set undofile            " Maintain undo history between sessions.
set undodir=~/.vim/undodir " Directory to vim undo files.
set spelllang=en_us "
set complete+=kspell    "
set incsearch           " Incremental search.
set hlsearch            " Highlight search.
set ignorecase          " Ignore case in searches.
set smartcase           " '' excepted if an uppercase letter is used.
set history=500         " Sets how many lines of history VIM has to remember.
set colorcolumn=80      " Add a colored column at 80.
set path+=**            " Used for nested file searching.
set wildmenu            " Show tab completion options.
set listchars=tab:o—,nbsp:_,trail:–
set list                " This and the above expose whitespace characters.
set foldmethod=indent   " Allows indented code folding.
set foldnestmax=10      "
set nofoldenable        "
set foldlevel=2         "
set tabstop=4           "      " [] Add context to these.
set softtabstop=4       "
set shiftwidth=4        "
set expandtab           "
set tags+=/usr/local/include/tags "
"
" Don't write backup file if vim is being called by "crontab -e"
au BufWrite /private/tmp/crontab.* set nowritebackup nobackup
"
" Don't write backup file if vim is being called by "chpass"
au BufWrite /private/etc/pw.* set nowritebackup nobackup
"
" Set proper indentation for html, css, & javascript.
autocmd FileType html setlocal tabstop=2 softtabstop=2 shiftwidth=2
autocmd FileType javascript setlocal tabstop=2 softtabstop=2 shiftwidth=2
"
" This function sets <leader>n to toggle between absolute and relative line
" numbers.
function! g:ToggleNuMode()
    if(&rnu == 1)
        set nornu
    else
        set rnu
    endif
endfunc
nnoremap <silent> <leader>n :call g:ToggleNuMode()<cr>
"
" This function sets <leader>n to toggle between absolute and relative line
" numbers.
function! g:ToggleSpellMode()
    if(&spell == 1)
        set nospell
    else
        set spell
    endif
endfunc
nnoremap <silent> <leader>s :call g:ToggleSpellMode()<cr>
"
" _____NERDTree_____
let NERDTreeShowHidden=1
let NERDTreeQuitOnOpen=1
"
" _____YouCompleteMe_____
" Set path for ycm's C autocompletion.
let g:ycm_global_ycm_extra_conf = "~/.vim/.ycm_extra_conf.py"
let g:ycm_show_diagnostics_ui = 0 " Needs to be off to use syntastic propersy.
let g:ycm_register_as_syntastic_checker=0
let g:ycm_add_preview_to_completeopt=1
let g:ycm_autoclose_preview_window_after_completion=1
let g:ycm_autoclose_preview_window_after_insertion=1
"
"_____ale_____
" Set ale to lint only in normal mode.
let g:ale_lint_on_text_changed = "normal"
let g:ale_lint_on_insert_leave = 1
"
"_____airline_____
" Set the theme for airline.
let g:airline_powerline_fonts = 1
let g:airline_theme='luna'
" Set tabline
let g:airline#extensions#tabline#enabled = 1
"
"================================
"  ___ _           _            |
" | _ \ |_  _ __ _(_)_ _  ___   |
" |  _/ | || / _` | | ' \(_-<   |
" |_| |_|\_,_\__, |_|_||_/__/   |
"            |___/              |
"================================
" Plugins installed with vimplug.
" Plugins will be downloaded under the specified directory.
call plug#begin('~/.vim/plugged')
"
" Declare the list of plugins.
Plug 'scrooloose/nerdtree'
Plug 'Valloric/YouCompleteMe'
Plug 'craigemery/vim-autotag'
Plug 'w0rp/ale'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'majutsushi/tagbar'
"
" List ends here. Plugins become visible to Vim after this call.
call plug#end()
