
"               ██╗   ██╗██╗███╗   ███╗
"               ██║   ██║██║████╗ ████║
"               ██║   ██║██║██╔████╔██║
"               ╚██╗ ██╔╝██║██║╚██╔╝██║
"                ╚████╔╝ ██║██║ ╚═╝ ██║
"                 ╚═══╝  ╚═╝╚═╝     ╚═╝
"               Trevor's configuration
"                file for Vim & NeoVim.

" ============================================================================
" ░█▀▀░█▀▀░▀█▀░▀█▀░▀█▀░█▀█░█▀▀░█▀▀
" ░▀▀█░█▀▀░░█░░░█░░░█░░█░█░█░█░▀▀█
" ░▀▀▀░▀▀▀░░▀░░░▀░░▀▀▀░▀░▀░▀▀▀░▀▀▀
" settings====================================================================
" Set vim colors.
syntax enable
" set background=dark

" Set vim behavior.
" set makeprg=cmd.exe\ /c\ wslBuild.bat " Set :make for tlcHandmadeHero
set autoindent          "
set autowrite           "
set backspace=2         " More powerful backspacing
set backup              " Enable backups
set backupdir=~/.vim/tmp//,.    " Backup working files to ~/.vim/tmp.
set cinkeys-=0#         " Stop vim from treating # indentation different.
set cinoptions+=#1s     " Indent with c-macros one shiftwidth. Used with cinkeys.
set colorcolumn=80      " Add a colored column at 80.
set complete+=kspell    "
set cursorline
set directory=~/.vim/tmp//,.    " Put swaps in ~/.vim/tmp.
set errorformat^=%+Gmake%.%#    " Remove makefile errors from error jump list.
set errorformat^=%-GIn\ file\ included\ %.%#   " General ignore format
set expandtab           "
set foldcolumn=1        " Makes folds visable in the sidebar
set foldlevel=2         "
set foldmethod=indent   " Allows indented code folding.
set foldnestmax=10      "
set hidden              " Allow buffer switching without saving.
set history=500         " Sets how many lines of history VIM has to remember.
set hlsearch            " Highlight search.
set ignorecase          " Ignore case in searches.
set incsearch           " Incremental search.
set lazyredraw          " Don't redraw the screen during application of macros
set list                " This and the above expose whitespace characters.
set listchars=tab:o—,nbsp:_,trail:– " Exposes whitespace characters.
set modelines=0         " CVE-2007-2438
set mouse=a             " Enable mouse support for gui and term with support.
set nocompatible        " Use Vim defaults instead of 100% vi compatibility
set nofixendofline      " Do not add or remove final end of line.
set nofoldenable        "
set nrformats+=alpha    " Make letters increment and decrement able.
set number              " Enable line numbers at startup.
set numberwidth=1       " Minimum number of columns to use fo line numbers
set path+=**            " Used for nested file searching.
set printoptions=number:y   " Adds numbers to :hardcopy command.
set scrolloff=10        " Keep at least 5 lines above and below the cursor.
set shiftwidth=4        "
set signcolumn=number   " Put signs in the number column instead of sign column.
set smartcase           " '' excepted if an uppercase letter is used.
set softtabstop=4       "
set spelllang=en_us     "
set splitbelow          "
set splitright          "
set tabstop=4           "      " [] Add context to these.
set tags+=/usr/local/include/tags "
set undodir=~/.vim/undodir  " Directory to vim undo files.
set undofile            " Maintain undo history between sessions.
set updatetime=500      " Faster refresh rate.
set wildmenu            " Show tab completion options.

" Allow specific filetype plugins for buffer only changes to settings.
filetype plugin on

" Cursor & Color Related settings.
" hi CursorLine term=NONE cterm=NONE ctermbg=black    "old
hi ColorColumn term=NONE ctermbg=236 ctermfg=NONE cterm=NONE
hi CursorLine term=NONE ctermbg=236 ctermfg=NONE cterm=NONE
hi FoldColumn ctermbg=NONE ctermfg=darkyellow cterm=bold guibg=darkgrey
hi Folded ctermfg=darkblue ctermbg=black
hi Pmenu ctermfg=15 ctermbg=236 guibg=Magenta
hi Search ctermfg=black ctermbg=yellow cterm=bold
hi SignColumn ctermbg=black ctermfg=darkyellow cterm=bold guibg=darkgrey
hi SpellBad ctermfg=darkred ctermbg=NONE cterm=reverse
hi Todo ctermfg=green ctermbg=NONE cterm=bold
hi VertSplit term=NONE ctermbg=NONE ctermfg=white cterm=NONE
hi Visual ctermfg=black ctermbg=darkyellow cterm=bold
hi debugPC ctermfg=darkyellow ctermbg=darkblue cterm=bold

au WinEnter * setlocal cursorline
au WinLeave * setlocal nocursorline

" Don't write backup file if vim is being called by "crontab -e"
au BufWrite /private/tmp/crontab.* set nowritebackup nobackup

" Don't write backup file if vim is being called by "chpass"
au BufWrite /private/etc/pw.* set nowritebackup nobackup

" Set 2 space indentation for certain file formats.
au FileType html,css,js,json,xsl,xml setlocal tabstop=2 softtabstop=2 shiftwidth=2

" Set syntax highlighting for misc. C++-like file extensions.
au BufEnter *.tpp :setlocal filetype=cpp

" Set proper tab character for make.
au FileType make,xml setlocal noexpandtab

" Set Rmarkdown render command
au Filetype rmd map <silent> <leader>r :!echo<space>"require(rmarkdown);<space>render('<c-r>%')"<space>\|<space>R<space>--vanilla<enter>


" ============================================================================
" ░█▄█░█▀█░█▀█░█▀█░▀█▀░█▀█░█▀▀░█▀▀
" ░█░█░█▀█░█▀▀░█▀▀░░█░░█░█░█░█░▀▀█
" ░▀░▀░▀░▀░▀░░░▀░░░▀▀▀░▀░▀░▀▀▀░▀▀▀
" mappings====================================================================
" Set <leader> to <space>.
let mapleader=" "

" Open split files vertically.
noremap <c-w>gf <c-w>vgf

" Remove search highlighting till next search.
nnoremap <silent> <leader><esc> :noh<cr>

" Use visual selection for search and replace.
vnoremap <C-r> "hy:%s/<C-r>h//g<left><left>

" Sort words alphabetically using a visual selection.
vnoremap <silent> <leader>s d:execute 'normal i' . join(sort(split(getreg('"'))), ' ')<cr>

" Ag search for visually selected.
vnoremap <silent> <leader>s y:Ag "<c-r>""<cr>

" Build ctags and cscope.
" nnoremap <silent> <leader>t :AsyncRun :silent !touch .root<cr>:silent !ctags *<cr>:silent !cscope -Rb<cr>
" Just create a .root in the current folder and have Gutentags do the rest.
nnoremap <silent> <leader>t :AsyncRun :silent !touch .root<cr>

" Open and close tags drawer.
nnoremap <silent> <leader>T :TagbarToggle<cr>

" Compile latex (.tex) documents from normal mode.
nnoremap <silent> <leader>l :w<cr>:!pdflatex %; xdg-open %:t:r.pdf<cr>

" Brace completion.
"inoremap {<cr> {<cr>}<esc>O            " Replaced with Auto-Pairs plugin

" Paren completion.
"inoremap (<cr> (<cr>)<esc>O            " Replaced with Auto-Pairs plugin

" Move to next fill character, staying in insert mode and removing highlight.
inoremap <C-h> <esc>/<##><cr>:noh<cr>"_c4l

" Trigger Codi scratchpad.
nnoremap <silent> <leader>x :Codi!!<cr>

" Allow gf to open non-existing files.
nmap gf :e <cfile><cr>

" Place fill character.
nmap <C-h> i<##><esc>

" Start fuzzy ripgrep file search
nnoremap <c-p> :Rg<cr>

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
nnoremap <silent> <leader>pd :w<cr>:ha>%.ps<cr>:!ps2pdf %.ps && rm %.ps<cr>

" Autocorrect next misspelled word.
nnoremap <silent> <leader>z ]s1z=

" Go to the next buffer
nnoremap <silent> <tab> :bn<cr>

" Go to the previous buffer
nnoremap <silent> <s-tab> :bp<cr>

" List available buffers
nnoremap <silent> <leader>b :ls<cr>:b<space>

" Close all but the current buffer.
command CloseAllButCurrent silent! execute "%bd|e#|bd#"
nnoremap <silent> <leader>dd :CloseAllButCurrent<cr>

" Visually select last changed or put text.
"nnoremap <expr> gp '`[' . strpart(getregtype(), 0, 1) . '`]'<Paste>
nnoremap gp `[v`]

" Switch to corresponding header/source file.
" You could use ".h" or ".c" filename endings by changing it in the
" replacement statements.
" nnoremap <silent> <leader>e :e %:p:s,.hpp$,.X123X,:s,.cpp$,.hpp,:s,.X123X$,.cpp,<cr>
" coc-clangd "clangd.switchSourceHeader" can do this as well.
nnoremap <silent> <leader>e :CocCommand clangd.switchSourceHeader<cr>

" Jump to previous item in quickfix after :make.
nnoremap <silent> <c-k> :cp<cr>

" Jump to next item in quickfix after :make.
nnoremap <silent> <c-j> :cn<cr>

" VimGrep the open buffers
nnoremap <silent> <leader>v :GrepBufs<c-l><space>

" VimGrep the word under the cursor within the open buffers.
nnoremap <silent> <leader>V :call GrepBuffers("<C-R><C-W>")<cr>

" Open fuzzy file browser
nnoremap <silent> <leader>4 :Files<cr>

" Repeat last entered colon command
nnoremap <silent> <leader>; @:

" Automatically form current buffer
nnoremap <silent> <F2> :Autoformat<cr>

if exists('g:AsyncRun')
    " Run :make
    nnoremap <silent> <leader>m :silent make -j4<cr>
    " Run :make clean.
    nnoremap <silent> <F4> :silent make clean<cr>:copen<cr>
    " Run :make and open the Quickfix menu.
    nnoremap <silent> <F9> :silent make rebuild<cr>:copen<cr>
else
    " Run make asynchronously
    nnoremap <silent> <leader>m :wa<cr>:AsyncRun make -j4<cr><c-w><c-w>
    " Run make clean asynchronously.
    nnoremap <silent> <F4> :wa<cr>:AsyncRun make clean<cr><c-w><c-w>
    " Run make asynchronously and open the Quickfix menu.
    nnoremap <silent> <F9> :wa<cr>:AsyncRun make rebuild<cr>:copen<cr><c-w><c-w>
endif

" Run an a.out program.
nnoremap <silent> <F5> :term ./a.out<cr>

" Run gdb with an a.out executable.
nnoremap <silent> <F8> :Termdebug a.out<cr>

" Toggle line number modes
nnoremap <silent> <leader>n :call g:ToggleNuMode()<cr>

" Open/close Quickfix drawer.
nnoremap <silent> <leader>q :call g:ToggleQuickfix()<cr>

" Jump to previous item in quickfix.
nnoremap <silent> <c-k> :cprev<cr>

" Jump to next item in quickfix.
nnoremap <silent> <c-j> :cnext<cr>

" Toggle spell mode.
nnoremap <silent> <leader>s :call g:ToggleSpellMode()<cr>

" Open and close project drawer, uses :Lexplore if there is no NERDTree.
nmap <silent> <leader><tab> :call g:ToggelFileBrowser()<cr>

" Execute a macro over a visually selected range.
xnoremap @ :<C-u>call ExecuteMacroOverVisualRange()<cr>

" Toggle Markdown Preview
nmap <leader>pm <Plug>MarkdownPreviewToggle

" Escape terminal command instert mode
tnoremap <esc> <c-\><c-n>

" ============================================================================
" ░█▀▀░█░█░█▀█░█▀▀░▀█▀░▀█▀░█▀█░█▀█░█▀▀
" ░█▀▀░█░█░█░█░█░░░░█░░░█░░█░█░█░█░▀▀█
" ░▀░░░▀▀▀░▀░▀░▀▀▀░░▀░░▀▀▀░▀▀▀░▀░▀░▀▀▀
" functions===================================================================
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

function! g:ToggleSpellMode()
    if(&spell == 1)
        set nospell
    else
        set spell
    endif
endfunc

function! g:ToggelFileBrowser()
    if exists('g:NERDTree')
        :NERDTreeToggle
    else
        :Explore
    endif
endfunc

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


" ============================================================================
" ░▀█▀░█▀█░█▀▀░█▀▀
" ░░█░░█▀█░█░█░▀▀█
" ░░▀░░▀░▀░▀▀▀░▀▀▀
" tags========================================================================

"" Set tagging for source code of file type.
"au Filetype c,cpp,h,hpp setlocal tags+=/usr/local/include/tags

" ============================================================================
" ░█▀█░█░░░█░█░█▀▀░▀█▀░█▀█░█▀▀
" ░█▀▀░█░░░█░█░█░█░░█░░█░█░▀▀█
" ░▀░░░▀▀▀░▀▀▀░▀▀▀░▀▀▀░▀░▀░▀▀▀
" plugins=====================================================================
"" Plugins install with packadd
packadd! termdebug

" ___Termdebug___
" Evaluate the expression under the cursor, you can also use K by default or
" use balloon_eval on hover.
nnoremap <RightMouse> :Evaluate<cr>

" Open vim terminal debugger
nnoremap <silent> <leader>db :Termdebug a.out<cr><c-w><c-h>

" Set window layout for Termdebug
let g:termdebug_wide=1

"" Plugins installed with vimplug.
" ___COC.nvim___
" source ~/.vim/coc-config.vim

" Disable python2 support, python2 is deprecated.
let g:loaded_python_provider = 0

" Always show the signcolumn, otherwise it would shift the text each time
" diagnostics appear/become resolved.
if has("patch-8.1.1564")
    " Recently vim can merge signcolumn and number column into one
    set signcolumn=number
else
    set signcolumn=yes
endif

" Use <F3> to show documentation in preview window.
nnoremap <silent> <F3> :call <SID>show_documentation()<CR>

function! s:show_documentation()
    if (index(['vim','help'], &filetype) >= 0)
        execute 'h '.expand('<cword>')
    elseif (coc#rpc#ready())
        call CocActionAsync('doHover')
    else
        execute '!' . &keywordprg . " . expand('<cword>')
    endif
endfunction

"" Symbol renaming.
"nmap <leader>rn <Plug>(coc-rename)
"nmap <leader>rf <Plug>(coc-refactor)
"nmap <leader>ra <Plug>(coc-codeaction)
"
"" GoTo code navigation.
"nmap <silent> gd <Plug>(coc-definition)
"nmap <silent> gy <Plug>(coc-type-definition)
"nmap <silent> gi <Plug>(coc-implementation)
"nmap <silent> gr <Plug>(coc-references)
"
"" Add `:Format` command to format current buffer.
"command! -nargs=0 Format :call CocAction('format')
"
"" Add `:Fold` command to fold current buffer.
"command! -nargs=? Fold :call     CocAction('fold', <f-args>)
"
"" Add `:OR` command for organize imports of the current buffer.
"command! -nargs=0 OR   :call     CocAction('runCommand', 'editor.action.organizeImport')

" ___NERDTree___
let g:NERDTreeShowHidden = 1
let g:NERDTreeQuitOnOpen = 1
let g:NERDTreeMinimalUI = 1 " hide helper
let g:NERDTreeIgnore = ['^node_modules$']
let g:NERDTreeStatusline = '' " set to empty to use lightline

" Close window if NERDTree is the last one
au BufEnter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif

" Map to open current file in NERDTree and set size
nnoremap <leader>pv :NERDTreeFind<bar> :vertical resize 45<CR>

" Enables folder icon highlighting using exact match
let g:NERDTreeHighlightFolders = 1

" Highlights the folder name
let g:NERDTreeHighlightFoldersFullName = 1

" Color customization
let s:brown = "905532"
let s:aqua =  "3AFFDB"
let s:blue = "689FB6"
let s:darkBlue = "44788E"
let s:purple = "834F79"
let s:lightPurple = "834F79"
let s:red = "AE403F"
let s:beige = "F5C06F"
let s:yellow = "F09F17"
let s:orange = "D4843E"
let s:darkOrange = "F16529"
let s:pink = "CB6F6F"
let s:salmon = "EE6E73"
let s:green = "8FAA54"
let s:lightGreen = "31B53E"
let s:white = "FFFFFF"
let s:rspec_red = 'FE405F'
let s:git_orange = 'F54D27'

" This line is needed to avoid error
let g:NERDTreeExtensionHighlightColor = {}

" Sets the color of css files to blue
let g:NERDTreeExtensionHighlightColor['css'] = s:blue

" This line is needed to avoid error
let g:NERDTreeExactMatchHighlightColor = {}

" Sets the color for .gitignore files
let g:NERDTreeExactMatchHighlightColor['.gitignore'] = s:git_orange

" This line is needed to avoid error
let g:NERDTreePatternMatchHighlightColor = {}

" Sets the color for files ending with _spec.rb
let g:NERDTreePatternMatchHighlightColor['.*_spec\.rb$'] = s:rspec_red

" Sets the color for folders that did not match any rule
let g:WebDevIconsDefaultFolderSymbolColor = s:beige

" Sets the color for files that did not match any rule
let g:WebDevIconsDefaultFileSymbolColor = s:blue

" NERDTree Git Plugin
let g:NERDTreeIndicatorMapCustom = {
            \ "Modified"  : "✹", "Staged"    : "✚", "Untracked" : "✭",
            \ "Renamed"   : "➜", "Unmerged"  : "═", "Deleted"   : "✖",
            \ "Dirty"     : "✗", "Clean"     : "✔︎", 'Ignored'   : '☒',
            \ "Unknown"   : "?"
            \ }

"___ale___
" Set ale to lint only in normal mode.
let g:ale_lint_on_text_changed = "normal"
let g:ale_lint_on_insert_leave = 1
let g:ale_set_balloons = 1
let g:ale_c_clangd_options = "-stdlib=libc++"
let g:ale_cpp_clangd_options = "-stdlib=libc++"

"___airline___
" Set the theme for airline.
let g:airline_theme='luna'
" let g:airline_theme = 'base16_grayscale'
" let g:airline_theme = 'minimalist'
" let g:airline_theme = 'monochrome'
let g:airline_powerline_fonts = 1
let g:airline#extensions#tabline#buffer_nr_show = 1
let g:airline#extensions#hunks#enabled = 0
let g:airline#extensions#branch#enabled = 1
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
" let g:airline_symbols.colnr = ' ㏇:'
let g:airline_symbols.colnr = ' ℅:'
let g:airline_symbols.crypt = '🔒'
let g:airline_symbols.linenr = '☰'
" let g:airline_symbols.linenr = ' ␊:'
" let g:airline_symbols.linenr = ' ␤:'
" let g:airline_symbols.linenr = '¶'
" let g:airline_symbols.maxlinenr = ''
" let g:airline_symbols.maxlinenr = '㏑'
" let g:airline_symbols.branch = '⎇'
" let g:airline_symbols.paste = 'ρ'
" let g:airline_symbols.paste = 'Þ'
let g:airline_symbols.paste = 'Þ'
let g:airline_symbols.spell = 'Ꞩ'
let g:airline_symbols.spell = ''
let g:airline_symbols.notexists = 'Ɇ'
let g:airline_symbols.whitespace = '∥'

" powerline symbols
" let g:airline_left_sep = ''
" let g:airline_left_alt_sep = ''
" let g:airline_right_sep = ''
" let g:airline_right_alt_sep = ''
" let g:airline_symbols.branch = ''
" let g:airline_symbols.colnr = ' :'

let g:airline_symbols.maxlinenr = 'Ξ'
let g:airline_symbols.dirty = '⚡'

" " old vim-powerline symbols
" let g:airline_left_sep = '⮀'
" let g:airline_left_alt_sep = '⮁'
" let g:airline_right_sep = '⮂'
" let g:airline_right_alt_sep = '⮃'
" let g:airline_symbols.branch = '⭠'
" let g:airline_symbols.readonly = '⭤'
" let g:airline_symbols.linenr = '⭡'
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
au! User GoyoEnter Limelight
au! User GoyoLeave Limelight!

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
" Enable gtags module
let g:gutentags_modules = ['ctags', 'gtags_cscope']

" Config project root markers.
let g:gutentags_project_root = ['.root', '.svn', '.git', 'package.json']

" Generate datebases in my cache directory, prevent gtags files polluting my project
let g:gutentags_cache_dir = expand('~/.cache/tags')

" Change focus to quickfix window after search (optional).
let g:gutentags_plus_switch = 1

" Specify when to generate tags
let g:gutentags_generate_on_new = 1
let g:gutentags_generate_on_missing = 1
let g:gutentags_generate_on_write = 1
let g:gutentags_generate_on_empty_buffer = 0

" Let Gutentags generate more info for tags
let g:gutentags_ctags_extra_args = [ '--tag-relative=yes', '--fields=+ailmnS' ]

" Ignored files and extentions.
let g:gutentags_ctags_exclude = [
            \ '*.git', '*.svg', '*.hg', '*/tests/*', 'build', 'dist',
            \ '*sites/*/files/*', 'bin', 'node_modules', 'bower_components',
            \ 'cache', 'compiled', 'docs', 'example', 'bundle', 'vendor',
            \ '*.md', '*-lock.json', '*.lock', '*bundle*.js', '*build*.js',
            \ '.*rc*', '*.json', '*.min.*', '*.map', '*.bak', '*.zip', '*.pyc',
            \ '*.class', '*.sln', '*.Master', '*.csproj', '*.tmp',
            \ '*.csproj.user', '*.cache', '*.pdb', 'tags*', 'cscope.*', '*.css',
            \ '*.less', '*.scss', '*.exe', '*.dll', '*.mp3', '*.ogg', '*.flac',
            \ '*.swp', '*.swo', '*.bmp', '*.gif', '*.ico', '*.jpg', '*.png',
            \ '*.rar', '*.zip', '*.tar', '*.tar.gz', '*.tar.xz', '*.tar.bz2',
            \ '*.pdf', '*.doc', '*.docx', '*.ppt', '*.pptx'
            \ ]

"___vimwiki___
let g:vimwiki_list = [{'path': '~/vimwiki', 'syntax:' : 'markdown', 'ext' : '.md'}]

"___fzf___
" set silversearche-ag be the default searching command, by file name
let $FZF_DEFAULT_COMMAND = 'ag -g ""'
let g:fzf_action = {'ctrl-t': 'tab split','ctrl-s': 'split','ctrl-v': 'vsplit'}

"___GitGutter___
hi GitGutterAdd ctermfg=green ctermbg=black guifg=#009900
hi GitGutterChange ctermfg=yellow ctermbg=black guifg=#bbbb00
hi GitGutterDelete ctermfg=red ctermbg=black guifg=#ff2222

"___Vimspector___
" let g:vimspector_enable_mappings = 'HUMAN'

"___Markdown-Preview___
let g:mkdp_auto_start = 1
let g:mkdp_auto_close = 1
let g:mkdp_refresh_slow = 0
let g:mkdp_command_for_global = 0
let g:mkdp_open_to_the_world = 0 " by default, the server listens on localhost (127.0.0.1)
let g:mkdp_open_ip = ''
let g:mkdp_browser = 'firefox'
let g:mkdp_echo_preview_url = 1

" a custom vim function name to open preview page
" this function will receive url as param
" default is empty
let g:mkdp_browserfunc = ''

" options for markdown render
" mkit: markdown-it options for render
" katex: katex options for math
" uml: markdown-it-plantuml options
" maid: mermaid options
" disable_sync_scroll: if disable sync scroll, default 0
" sync_scroll_type: 'middle', 'top' or 'relative', default value is 'middle'
"   middle: mean the cursor position alway show at the middle of the preview page
"   top: mean the vim top viewport alway show at the top of the preview page
"   relative: mean the cursor position alway show at the relative positon of the preview page
" hide_yaml_meta: if hide yaml metadata, default is 1
" sequence_diagrams: js-sequence-diagrams options
" content_editable: if enable content editable for preview page, default: v:false
" disable_filename: if disable filename header for preview page, default: 0
let g:mkdp_preview_options = {
            \ 'mkit': {},
            \ 'katex': {},
            \ 'uml': {},
            \ 'maid': {},
            \ 'disable_sync_scroll': 0,
            \ 'sync_scroll_type': 'middle',
            \ 'hide_yaml_meta': 1,
            \ 'sequence_diagrams': {},
            \ 'flowchart_diagrams': {},
            \ 'content_editable': v:false,
            \ 'disable_filename': 0
            \ }

" use a custom markdown style must be absolute path
" like '/Users/username/markdown.css' or expand('~/markdown.css')
let g:mkdp_markdown_css = ''

" use a custom highlight style must absolute path
" like '/Users/username/highlight.css' or expand('~/highlight.css')
let g:mkdp_highlight_css = ''

" use a custom port to start server or random for empty
let g:mkdp_port = ''

" preview page title
" ${name} will be replace with the file name
let g:mkdp_page_title = '「${name}」'

" recognized filetypes
" these filetypes will have MarkdownPreview... commands
let g:mkdp_filetypes = ['markdown']

"========================================================
" Plugins will be downloaded under the specified directory.
call plug#begin('~/.vim/plugged')

" NOTE: Anything to do with tags and language servers in specific require
"       configuration. Be sure that they are properly configured or they wont
"       work.  Other plugins that are commented out here are things I use only
"       on occasion to better fit the work I am doing. (non-code based
"       writing).

" Declare the list of plugins.
Plug 'Chiel92/vim-autoformat'               " Autoformatting of code
Plug 'SirVer/ultisnips'
Plug 'airblade/vim-gitgutter'
Plug 'ap/vim-css-color'                     " Add css color previews.
Plug 'chaoren/vim-wordmotion'               " Move by camalCase and snake_case
Plug 'iamcco/markdown-preview.nvim', { 'do': 'cd app && yarn install' } " The name
Plug 'jiangmiao/auto-pairs'                 " Autocomplete scopes and more.
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } } " Fuzzy searching of files.
Plug 'junegunn/fzf.vim'                     " ^
Plug 'junegunn/goyo.vim'                    " Minimal interface.
Plug 'junegunn/limelight.vim'               " Dims unfocused text sections.
Plug 'ludovicchabant/vim-gutentags'         " Provides ctag management.
Plug 'ludovicchabant/vim-gutentags'         " Provides tag management.
Plug 'mattn/emmet-vim'                      " Web code abbreviation tool.
Plug 'metakirby5/codi.vim'                  " Interactive scratchpad
Plug 'mhinz/vim-startify'                   " Add vim home screen.
Plug 'mtdl9/vim-log-highlighting'           " Highlighting for log files.
Plug 'neoclide/coc.nvim', {'branch': 'release'} " Completion engine, primary.
Plug 'octol/vim-cpp-enhanced-highlight'
Plug 'preservim/tagbar'                     " Tag browser for ctags.
" Plug 'puremourning/vimspector'              " Vim graphical debugger
Plug 'rking/ag.vim'                         " Silver file searcher
Plug 'scrooloose/nerdtree'
Plug 'skywind3000/asyncrun.vim'
Plug 'skywind3000/gutentags_plus'           " Extends gutentags capabilities.
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-surround'                   " Surround text objects.
Plug 'vim-airline/vim-airline'              " Adds styled statusbars.
Plug 'vim-airline/vim-airline-themes'       " Themes for airline.
Plug 'vimwiki/vimwiki'
Plug 'w0rp/ale'                             " Linting engine.
Plug 'will133/vim-dirdiff'                  " Diff whole directories
" List ends here. Plugins become visible to Vim after this call.
call plug#end()
