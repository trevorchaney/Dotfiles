"
"               ██╗   ██╗██╗███╗   ███╗
"               ██║   ██║██║████╗ ████║
"               ██║   ██║██║██╔████╔██║
"               ╚██╗ ██╔╝██║██║╚██╔╝██║
"                ╚████╔╝ ██║██║ ╚═╝ ██║
"                 ╚═══╝  ╚═╝╚═╝     ╚═╝
"               Trevor's configuration
"                   file for Vim.
"
"
"===================================
"   ___                       _    |
"  / __|___ _ _  ___ _ _ __ _| |   |
" | (_ / -_) ' \/ -_) '_/ _` | |   |
"  \___\___|_||_\___|_| \__,_|_|   |
"                                  |
"===================================
" _____Mappings_____
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
inoremap {<cr> {<cr>}<esc>O<tab>
" Paren completion.
inoremap (<cr> (<cr>)<esc>O<tab>
" Move to next fill character, staying in insert mode and removing highlight.
inoremap <C-h> <esc>/<##><cr>:noh<cr>"_c4l
" Increment a number.
nnoremap <silent> <leader>c :Codi!!<cr>
nnoremap <C-k> <C-A>
" Decrement a number.
nnoremap <C-j> <C-X>
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
" Open and close project drawer.
nmap <silent> <leader><tab> :NERDTreeToggle<CR>
"cnoremap w<cr> w<cr>:!ctags<cr>    " Replaced with Plugin 'vim-autotag'
"nnoremap <leader>9 bcw()<esc>P
" List available buffers                                                        
nnoremap <silent> <leader>b :ls<cr>:b<space>                                    
" Make the current file into a pdf.                                             
nnoremap <silent> <leader>p :w<cr>:ha>%.ps<cr>:!ps2pdf %.ps && rm %.ps<cr>
"
"" Set vim colors.
"syntax enable
"set background=dark
"colorscheme solarized
""
"" Enable transparency set by emulator. Must be after colorscheme.
"hi Normal guibg=NONE ctermbg=NONE
"
" Set vim behavior.
set modelines=0         " CVE-2007-2438
set nocompatible        " Use Vim defaults instead of 100% vi compatibility
set backspace=2         " More powerful backspacing
set nu                  " Enable line numbers at startup.
set undofile            " Maintain undo history between sessions.
set undodir=~/.vim/undodir  " Directory to vim undo files.
set spelllang=en_us     "
set complete+=kspell    "
set mouse=a             " Enable mouse support for gui and term with support.
set incsearch           " Incremental search.
set hlsearch            " Highlight search.
set ignorecase          " Ignore case in searches.
set smartcase           " '' except if an uppercase letter is used.
set history=500         " Sets how many lines of history VIM has to remember.
set hidden              " Allow buffer switching without saving.
set colorcolumn=80      " Add a colored column at 80.
set path+=**            " Used for nested file searching.
set wildmenu            " Show tab completion options.
set listchars=tab:o—,nbsp:_,trail:– " Exposes whitespace characters.
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
set autowrite
set cursorline
hi CursorLine term=NONE cterm=None ctermbg=black
au WinEnter * setlocal cursorline
au WinLeave * setlocal nocursorline
"
"=_=========================
"| |_ __ _  __ _  __ _ ___
"| __/ _` |/ _` |/ _` / __|
"| || (_| | (_| | (_| \__ \
" \__\__,_|\__, |\__, |___/
"          |___/ |___/
"===========================
" Set tagging for source code of file type.
autocmd Filetype cpp,c,h,hpp setlocal tags+=/usr/local/include/tags
"
" TODO:[] Fix this shit.
"autocmd Filetype py setlocal tags+=/usr/local/Cellar/python3/3.6.4_2/Frameworks/Python.framework/Versions/3.6/lib/python3.6/site-packages/tags
"autocmd Filetype py setlocal tags+=/usr/local/Cellar/python3/3.6.4_2/Frameworks/Python.framework/Versions/3.6/lib/python3.6/tags
"
"============================
"
" Don't write backup file if vim is being called by "crontab -e"
au BufWrite /private/tmp/crontab.* set nowritebackup nobackup
"
" Don't write backup file if vim is being called by "chpass"
au BufWrite /private/etc/pw.* set nowritebackup nobackup
"
" Set proper indentation for html, css, & javascript.
autocmd FileType html,css,javascript setlocal tabstop=2 softtabstop=2 shiftwidth=2
"
" Set proper tab indent for make.
autocmd FileType make setlocal noexpandtab
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
" This function sets <leader>s to toggle spellcheck on and off.
function! g:ToggleSpellMode()
    if(&spell == 1)
        set nospell
    else
        set spell
    endif
endfunc
nnoremap <silent> <leader>s :call g:ToggleSpellMode()<cr> 
"
" Allows for running macros over all visually selected lines with @.
function! ExecuteMacroOverVisualRange()
    echo "@".getcmdline()
    execute ":'<, '>normal @".nr2char(getchar())
endfunc
xnoremap @ :<C-u>call ExecuteMacroOverVisualRange()<CR>
"
" _____Rmarkdown_____
"
autocmd Filetype rmd map <silent> <leader>r :!echo<space>"require(rmarkdown);<space>render('<c-r>%')"<space>\|<space>R<space>--vanilla<enter>
"
" _____NERDTree_____
let NERDTreeShowHidden=1
let NERDTreeQuitOnOpen=1
"
" _____YouCompleteMe_____
" Set path for ycm's C autocompletion.
let g:ycm_global_ycm_extra_conf = "~/.vim/.ycm_extra_conf.py"
" Set path for python autocompleteion
let g:ymc_python_binary_path = "/usr/bin/python3"
let g:ycm_show_diagnostics_ui = 0 " Needs to be off to use syntastic properly.
let g:jedi#force_py_version = 3
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
Plug 'ludovicchabant/vim-gutentags'
Plug 'w0rp/ale'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'majutsushi/tagbar'
Plug 'metakirby5/codi.vim'                  " Interactive scratchpad
"Plug 'jaxbot/browserlink.vim'               " Live browser editing
Plug 'mattn/emmet-vim'
Plug 'Chiel92/vim-autoformat'               " Autoformatting of code
Plug 'Xuyuanp/nerdtree-git-plugin'          " Git plugin for nerdtree
Plug 'nathanaelkane/vim-indent-guides'      " Indent Guides
Plug 'rking/ag.vim'                         " Silver searcher searching
" List ends here. Plugins become visible to Vim after this call.
call plug#end()
