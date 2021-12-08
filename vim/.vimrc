"
"               ██╗   ██╗██╗███╗   ███╗
"               ██║   ██║██║████╗ ████║
"               ██║   ██║██║██╔████╔██║
"               ╚██╗ ██╔╝██║██║╚██╔╝██║
"                ╚████╔╝ ██║██║ ╚═╝ ██║
"                 ╚═══╝  ╚═╝╚═╝     ╚═╝
"               Trevor's configuration
"                file for Vim & NeoVim.


"=____=======_===_===_===================
"/ ___|  ___| |_| |_(_)_ __   __ _ ___  |
"\___ \ / _ \ __| __| | '_ \ / _` / __| |
" ___) |  __/ |_| |_| | | | | (_| \__ \ |
"|____/ \___|\__|\__|_|_| |_|\__, |___/ |
"                            |___/      |
"========================================

" Set vim colors.
syntax enable
set background=dark

"" Enable transparency set by emulator. Must be after colorscheme.
"hi Normal guibg=NONE ctermbg=NONE

" Set vim behavior.
"set makeprg=cmd.exe\ /c\ wslBuild.bat " Set :make for tlcHandmadeHero
set autoindent          "
set autowrite           "
set backspace=2         " More powerful backspacing
set backup              " Enable backups
set backupdir=$HOME/.vim/tmp//,.    " Backup working files to ~/.vim/tmp.
set cinkeys-=0#         " Stop vim from treating # indentation different.
set cinoptions+=#1s     " Indent with c-macros one s-width. used with cinkeys.
set colorcolumn=80      " Add a colored column at 80.
set complete+=kspell    "
set cursorline
set directory=$HOME/.vim/tmp//,.    " Put swaps in ~/.vim/tmp.
set errorformat^=%+Gmake%.%#    " Remove makefile errors from error jump list.
set errorformat^=%-GIn\ file\ included\ %.%#   " General ignore format
set expandtab           "
set foldlevel=2         "
set foldmethod=indent   " Allows indented code folding.
set foldnestmax=10      "
set hidden              " Allow buffer switching without saving.
set history=500         " Sets how many lines of history VIM has to remember.
set hlsearch            " Highlight search.
set ignorecase          " Ignore case in searches.
set incsearch           " Incremental search.
set list                " This and the above expose whitespace characters.
set listchars=tab:o-,nbsp:_,trail:- " Exposes whitespace characters.
set modelines=0         " CVE-2007-2438
set mouse=a             " Enable mouse support for gui and term with support.
set nocompatible        " Use Vim defaults instead of 100% vi compatibility
set nofixendofline      " Do not add or remove final end of line.
set nofoldenable        "
set nrformats+=alpha    " Make letters increment and decrement able.
set nu                  " Enable line numbers at startup.
set path+=**            " Used for nested file searching.
set printoptions=number:y   " Adds numbers to :hardcopy command.
set scrolloff=5         " Keep at least 5 lines above and below the cursor.
set shiftwidth=4        "
set smartcase           " '' excepted if an uppercase letter is used.
set softtabstop=4       "
set spelllang=en_us     "
set tabstop=4           "      " [] Add context to these.
set tags+=/usr/local/include/tags "
set undodir=$HOME/.vim/undodir  " Directory to vim undo files.
set undofile            " Maintain undo history between sessions.
set updatetime=300      " Faster refresh rate.
set wildmenu            " Show tab completion options.

" Cursor & Color Related settings.
" hi CursorLine term=NONE cterm=NONE ctermbg=black
hi CursorLine term=NONE ctermbg=236 ctermfg=NONE cterm=NONE
hi ColorColumn term=NONE ctermbg=236 ctermfg=NONE cterm=NONE
hi VertSplit term=NONE ctermbg=NONE ctermfg=white cterm=NONE
hi Pmenu ctermfg=15 ctermbg=236 guibg=Magenta
hi Folded ctermfg=darkblue ctermbg=black
hi Search ctermfg=black ctermbg=yellow cterm=bold
hi Visual ctermfg=black ctermbg=darkyellow cterm=bold
hi SpellBad ctermfg=darkred ctermbg=NONE cterm=reverse
hi Todo ctermfg=green ctermbg=NONE cterm=bold
au WinEnter * setlocal cursorline
au WinLeave * setlocal nocursorline

" Don't write backup file if vim is being called by "crontab -e"
au BufWrite /private/tmp/crontab.* set nowritebackup nobackup

" Don't write backup file if vim is being called by "chpass"
au BufWrite /private/etc/pw.* set nowritebackup nobackup

" Set 2 space indentation for certain file formats.
autocmd FileType html,css,javascript,xsl,xml setlocal tabstop=2 softtabstop=2 shiftwidth=2

" Set syntax highlighting for misc. C++ file extensions.
autocmd BufEnter *.tpp :setlocal filetype=cpp

" Set proper tab character for make.
autocmd FileType make,xml setlocal noexpandtab

" Set Rmarkdown render command
autocmd Filetype rmd map <silent> <leader>r :!echo<space>"require(rmarkdown);<space>render('<c-r>%')"<space>\|<space>R<space>--vanilla<enter>


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

" Use visual selection for search and replace.
vnoremap <C-r> "hy:%s/<C-r>h//g<left><left>

" Build tags.
nnoremap <silent> <leader>t :!ctags &<cr>

" Open and close tags drawer.
nnoremap <silent> <leader><s-t> :TagbarToggle<cr>

" Compile latex (.tex) documents from normal mode.
nnoremap <silent> <leader>l :w<cr>:!pdflatex %; xdg-open %:t:r.pdf<cr>

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

" Allow gf to open non-existing files.
nmap gf :e <cfile><cr>

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

" List available buffers
nnoremap <silent> <leader>b :ls<cr>:b<space>

" Make the current file into a pdf.
nnoremap <silent> <leader>p :w<cr>:ha>%.ps<cr>:!ps2pdf %.ps && rm %.ps<cr>

" Autocorrect next misspelled word.
nnoremap <silent> <leader>z ]s1z=

" Close all but the current buffer.
command CloseAllButCurrent silent! execute "%bd|e#|bd#"
nnoremap <silent> <leader>d :CloseAllButCurrent<cr>

" Visually select last changed or put text.
"nnoremap <expr> gp '`[' . strpart(getregtype(), 0, 1) . '`]'<Paste>
nnoremap gp `[v`]

" Switch to corresponding header/source file.
" You could use ".hpp" or ".c" filename endings by changing it in the
" replacement statements. (see COC Plugin)
" coc-clangd "clangd.switchSourceHeader" can do this as well.
nnoremap <silent> <leader>e :e %:p:s,.hpp$,.X123X,:s,.cpp$,.hpp,:s,.X123X$,.cpp,<cr>

" VimGrep the open buffers
nnoremap <silent> <leader>v :GrepBufs<c-l><space>

" VimGrep the word under the cursor within the open buffers.
nnoremap <silent> <leader>V :call GrepBuffers("<C-R><C-W>")<cr>

" Open fuzzy file browser
nnoremap <silent> <leader>4 :Files<cr>

" Repeat lost entered colon command
nnoremap <silent> <leader>2 @:

" Run :make
nnoremap <silent> <leader>m :silent make -j4<cr>

" Run :make clean.
nnoremap <silent> <F2> :silent make clean<cr>

" Run :make and then run the a.out program.
nnoremap <silent> <F3> :silent make clean<cr>:silent make<cr>:copen<cr>

" Run an a.out program.
nnoremap <silent> <F5> :term ./a.out<cr>

" Jump to next item in quickfix after :make.
nnoremap <silent> <F6> :cn<cr>

" Jump to previous item in quickfix after :make.
nnoremap <silent> <F7> :cp<cr>

" Run gdb with an a.out executable.
nnoremap <silent> <F8> :term gdb a.out<cr>

" Run :make and open the Quickfix menu.
nnoremap <silent> <F9> :silent make rebuild<cr>:copen<cr>

" Run :make clean.
"nnoremap <silent> <c-F9> :make clean<cr>

" Run :make and then run the a.out program.
"nnoremap <silent> <s-F9> :silent make<cr>:copen<cr>:term ./a.out<cr>

" Run :make clean && make, aka. rebuild and open the Quickfix menu.
" NOTE: Figure out how to call remapped keys, I'd guess that they would have
"       to defined in order for stuff like this to work.
"nnoremap <silent> <leader><F7> <F6><F7>

" Toggle line number modes
nnoremap <silent> <leader>n :call g:ToggleNuMode()<cr>

" Open Quickfix drawer.
nnoremap <silent> <leader>q :call g:ToggleQuickfix()<cr>

" Toggle spell mode.
nnoremap <silent> <leader>s :call g:ToggleSpellMode()<cr>

" Open and close project drawer, uses :Lexplore if there is no NERDTree.
nmap <silent> <leader><tab> :call g:ToggelFileBrowser()<cr>

" Execute a macro over a visually selected range.
xnoremap @ :<C-u>call ExecuteMacroOverVisualRange()<cr>


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

" Sets <leader>s to toggle spelling markup.
function! g:ToggleSpellMode()
    if(&spell == 1)
        set nospell
    else
        set spell
    endif
endfunc

" Set <leader><tab> to open and close file browser.
function! g:ToggelFileBrowser()
    if exists('g:NERDTree')
        :NERDTreeToggle
    else
        :Explore
    endif
endfunc

" Set <control><f7> to open and close the quickfix.
function! g:ToggleQuickfix()
    for i in range(1, winnr('$'))
        let bnum = winbufnr(i)
        if getbufvar(bnum, '&buftype') == 'quickfix'
            cclose
            return
        endif
    endfor
    copen
endfunction

function! BufferList()
    let all = range(0, bufnr('$'))
    let res = []
    for b in all
        if buflisted(b)
            call add(res, bufname(b))
        endif
    endfor
    return res
endfunction

function! GrepBuffers(expression)
    exec 'vimgrep/'.a:expression.'/'.join(BufferList())
endfunction
command! -nargs=+ GrepBufs call GrepBuffers(<q-args>)

" Allows for running macros over all visually selected lines with @.
function! ExecuteMacroOverVisualRange()
    echo "@".getcmdline()
    execute ":'<, '>normal @".nr2char(getchar())
endfunc


""=_==========================
""| |_ __ _  __ _  __ _ ___  |
""| __/ _` |/ _` |/ _` / __| |
""| || (_| | (_| | (_| \__ \ |
"" \__\__,_|\__, |\__, |___/ |
""          |___/ |___/      |
""============================

"" Set tagging for source code of file type.
"autocmd Filetype c,cpp,h,hpp setlocal tags+=/usr/local/include/tags

"" TODO:[] Fix this shit.
""autocmd Filetype py setlocal tags+=/usr/local/Cellar/python3/3.6.4_2/Frameworks/Python.framework/Versions/3.6/lib/python3.6/site-packages/tags
""autocmd Filetype py setlocal tags+=/usr/local/Cellar/python3/3.6.4_2/Frameworks/Python.framework/Versions/3.6/lib/python3.6/tags

"==___=_===========_=============
" | _ \ |_  _ __ _(_)_ _  ___   |
" |  _/ | || / _` | | ' \(_-<   |
" |_| |_|\_,_\__, |_|_||_/__/   |
"            |___/              |
"================================
" Plugins installed with vimplug.

" " ___COC.nvim___
" source ~/.vim/coc-config.vim

" " Disable python2 support, python2 is deprecated.
" let g:loaded_python_provider = 0

" " Always show the signcolumn, otherwise it would shift the text each time
" " diagnostics appear/become resolved.
" if has("patch-8.1.1564")
"   " Recently vim can merge signcolumn and number column into one
"   set signcolumn=number
" else
"   set signcolumn=yes
" endif

" " Use K to show documentation in preview window.
" nnoremap <silent> <F3> :call <SID>show_documentation()<CR>

" function! s:show_documentation()
"   if (index(['vim','help'], &filetype) >= 0)
"     execute 'h '.expand('<cword>')
"   elseif (coc#rpc#ready())
"     call CocActionAsync('doHover')
"   else
"     execute '!' . &keywordprg . " " . expand('<cword>')
"   endif
" endfunction

" " Symbol renaming.
" nmap <leader>rn <Plug>(coc-rename)

" " GoTo code navigation.
" nmap <silent> gd <Plug>(coc-definition)
" nmap <silent> gy <Plug>(coc-type-definition)
" nmap <silent> gi <Plug>(coc-implementation)
" nmap <silent> gr <Plug>(coc-references)

" nnoremap <silent> <leader>e :CocCommand clangd.switchSourceHeader<cr>

" " Add `:Format` command to format current buffer.
" command! -nargs=0 Format :call CocAction('format')

" " Add `:Fold` command to fold current buffer.
" command! -nargs=? Fold :call     CocAction('fold', <f-args>)

" " Add `:OR` command for organize imports of the current buffer.
" command! -nargs=0 OR   :call     CocAction('runCommand', 'editor.action.organizeImport')

" ___NERDTree___
let NERDTreeShowHidden=1
let NERDTreeQuitOnOpen=1

"___ale___
" Set ale to lint only in normal mode.
let g:ale_lint_on_text_changed = "normal"
let g:ale_lint_on_insert_leave = 1

"___airline___
" Set the theme for airline.
let g:airline_theme='luna'
"let g:airline_theme='base16_grayscale'
"let g:airline_theme='minimalist'
"let g:airline_theme='monochrome'
let g:airline_powerline_fonts = 1
let g:airline#extensions#tabline#buffer_nr_show=1
let g:airline#extensions#hunks#enabled=0
let g:airline#extensions#branch#enabled=1
let g:airline#extensions#tabline#enabled = 1
if !exists('g:airline_symbols')
    let g:airline_symbols = {}
endif

" ----------------------------------------------------------------------------
"NOTE: If you cant see some of the following symbols then either your terminal
"      doesn't render them or your font doesn't support them. Try using a
"      different terminal and if it still doesn't work then its your font and
"      you need to install a font that supports powerline fonts. Try a font
"      from the NerdFonts collection of patched fonts. Otherwise, uncomment
"      the fonts symbols that aren't broken below.
" ----------------------------------------------------------------------------

" unicode symbols
let g:airline_left_sep = '»'
let g:airline_left_sep = '▶'
let g:airline_right_sep = '«'
let g:airline_right_sep = '◀'
let g:airline_symbols.colnr = ' ㏇:'
let g:airline_symbols.colnr = ' ℅:'
let g:airline_symbols.crypt = '🔒'
let g:airline_symbols.linenr = '☰'
let g:airline_symbols.linenr = ' ␊:'
let g:airline_symbols.linenr = ' ␤:'
let g:airline_symbols.linenr = '¶'
let g:airline_symbols.maxlinenr = ''
let g:airline_symbols.maxlinenr = '㏑'
let g:airline_symbols.branch = '⎇'
let g:airline_symbols.paste = 'ρ'
let g:airline_symbols.paste = 'Þ'
let g:airline_symbols.paste = '∥'
let g:airline_symbols.spell = 'Ꞩ'
let g:airline_symbols.spell = ''
let g:airline_symbols.notexists = 'Ɇ'
let g:airline_symbols.whitespace = 'Ξ'

"" powerline symbols
"let g:airline_left_sep = ''
"let g:airline_left_alt_sep = ''
"let g:airline_right_sep = ''
"let g:airline_right_alt_sep = ''
"let g:airline_symbols.branch = ''
"let g:airline_symbols.colnr = ' :'
"let g:airline_symbols.readonly = ''
"let g:airline_symbols.linenr = ' :'
"let g:airline_symbols.maxlinenr = '☰ '
"let g:airline_symbols.dirty='⚡'

"" old vim-powerline symbols
"let g:airline_left_sep = '⮀'
"let g:airline_left_alt_sep = '⮁'
"let g:airline_right_sep = '⮂'
"let g:airline_right_alt_sep = '⮃'
"let g:airline_symbols.branch = '⭠'
"let g:airline_symbols.readonly = '⭤'
"let g:airline_symbols.linenr = '⭡'
" --------------

"___LimeLight___
" Color name (:help cterm-colors) or ANSI code
let g:limelight_conceal_ctermfg = 'gray'
let g:limelight_conceal_ctermfg = 240

" Color name (:help gui-colors) or RGB color
let g:limelight_conceal_guifg = 'DarkGray'
let g:limelight_conceal_guifg = '#777777'

" Default: 0.5
let g:limelight_default_coefficient = 0.7

" Number of preceding/following paragraphs to include (default: 0)
let g:limelight_paragraph_span = 1

" Beginning/end of paragraph
"   When there's no empty line between the paragraphs
"   and each paragraph starts with indentation
let g:limelight_bop = '^\s'
let g:limelight_eop = '\ze\n^\s'

" Highlighting priority (default: 10)
"   Set it to -1 not to overrule hlsearch
let g:limelight_priority = -1

" Have Goyo start/stop Limelight whenever Goyo is entered/left.
autocmd! User GoyoEnter Limelight
autocmd! User GoyoLeave Limelight!

"___Vim-Cpp-Enhanced-Highlight___"
let g:cpp_class_scope_highlight = 1
let g:cpp_member_variable_highlight = 1
let g:cpp_class_decl_highlight = 1
let g:cpp_posix_standard = 1
"let g:cpp_experimental_simple_template_highlight = 1
let g:cpp_experimental_template_highlight = 1   " Faster than above
let g:cpp_concepts_highlight = 1
"let g:cpp_no_function_highlight = 1

"___Gutentags___
let g:gutentags_ctags_exclude = [
            \ '*.git', '*.svg', '*.hg', '*/tests/*', 'build', 'dist',
            \ '*sites/*/files/*', 'bin', 'node_modules', 'bower_components', 'cache',
            \ 'compiled', 'docs', 'example', 'bundle', 'vendor', '*.md',
            \ '*-lock.json', '*.lock', '*bundle*.js', '*build*.js', '.*rc*',
            \ '*.json', '*.min.*', '*.map', '*.bak', '*.zip', '*.pyc', '*.class',
            \ '*.sln', '*.Master', '*.csproj', '*.tmp', '*.csproj.user', '*.cache',
            \ '*.pdb', 'tags*', 'cscope.*', '*.css', '*.less', '*.scss', '*.exe',
            \ '*.dll', '*.mp3', '*.ogg', '*.flac', '*.swp', '*.swo', '*.bmp',
            \ '*.gif', '*.ico', '*.jpg', '*.png', '*.rar', '*.zip', '*.tar',
            \ '*.tar.gz', '*.tar.xz', '*.tar.bz2', '*.pdf', '*.doc', '*.docx',
            \ '*.ppt', '*.pptx'
            \ ]

"========================================================
" Plugins will be downloaded under the specified directory.
call plug#begin('$HOME/.vim/plugged')

" NOTE: Anything to do with tags in specific require configuration. Be sure
"       that they are properly configured or they wont work. Other plugins
"       that are commented out here are things I use only on occasion to
"       better fit the work I am doing. (non-code based writing).

" Declare the list of plugins.
" Plug 'neoclide/coc.nvim', {'branch': 'release'} " Completion engine, primary.
" Plug 'octol/vim-cpp-enhanced-highlight'
Plug 'Chiel92/vim-autoformat'               " Autoformatting of code
Plug 'SirVer/ultisnips'
Plug 'airblade/vim-gitgutter'
Plug 'chaoren/vim-wordmotion'               " Move by camalCase and snake_case
Plug 'jiangmiao/auto-pairs'                 " Autocomplete scopes and more.
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } } " Fuzzy searching of files.
Plug 'junegunn/fzf.vim'                     " ^
Plug 'junegunn/goyo.vim'                    " Minimal interface.
Plug 'junegunn/limelight.vim'               " Dims unfocused text sections.
Plug 'ludovicchabant/vim-gutentags'         " Provides tag management.
Plug 'mattn/emmet-vim'                      " Web code abbreviation tool.
Plug 'metakirby5/codi.vim'                  " Interactive scratchpad
Plug 'mtdl9/vim-log-highlighting'           " Highlighting for log files.
Plug 'nathanaelkane/vim-indent-guides'      " Indent Guides
Plug 'preservim/tagbar'                     " Tag browser for ctags.
Plug 'rking/ag.vim'                         " Silver file searcher
Plug 'scrooloose/nerdtree'
Plug 'skywind3000/gutentags_plus'           " Extends gutentags capabilities.
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-surround'                   " Surround text objects.
Plug 'vim-airline/vim-airline'              " Adds styled statusbars.
Plug 'vim-airline/vim-airline-themes'       " Themes for airline.
Plug 'w0rp/ale'                             " Linting engine.
Plug 'will133/vim-dirdiff'                  " Diff whole directories
" List ends here. Plugins become visible to Vim after this call.
call plug#end()
