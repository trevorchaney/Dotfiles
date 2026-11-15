"
"               ██╗   ██╗██╗███╗   ███╗
"               ██║   ██║██║████╗ ████║
"               ██║   ██║██║██╔████╔██║
"               ╚██╗ ██╔╝██║██║╚██╔╝██║
"                ╚████╔╝ ██║██║ ╚═╝ ██║
"                 ╚═══╝  ╚═╝╚═╝     ╚═╝
"               Trevor's configuration
"                file for Vim & NeoVim
"
" TODO(tlc): This config should probably be rewritten as a Lua-based Neovim
"            config using lazy.nvim, following the omarchy-nvim setup as a
"            reference. See:
"              - Omarchy nvim config: /usr/share/omarchy-nvim/config/
"              - Omarchy nvim source: ~/pars/storage/repos/omarchy/install/packaging/nvim.sh
"              - LazyVim docs: https://lazyvim.org
"
" ============================================================================
" ░█▀▀░█▀▀░▀█▀░▀█▀░▀█▀░█▀█░█▀▀░█▀▀
" ░▀▀█░█▀▀░░█░░░█░░░█░░█░█░█░█░▀▀█
" ░▀▀▀░▀▀▀░░▀░░░▀░░▀▀▀░▀░▀░▀▀▀░▀▀▀
" settings ===================================================================
" Set vim colors
syntax enable
" Set background=dark

" Set vim behavior. TODO(tlc): Add context to these.
" set makeprg=cmd.exe\ /c\ wslBuild.bat " Set :make for microsoft programming
set autoindent                               "
set autowrite                                "
set backspace=2                              " More powerful backspacing
set backup                                   " Enable backups
set backupdir=~/.vim/tmp//,.                 " Backup working files to ~/.vim/tmp
set cinkeys-=0#                              " Stop vim from treating # indentation different
set cinoptions+=#1s                          " Indent with c-macros one shiftwidth. Used with cinkeys
set colorcolumn=80,120                       " Adds a colored column at the specified column
set complete+=kspell                         "
set cursorline                               "
set directory=~/.vim/tmp//,.                 " Put swaps in ~/.vim/tmp
set errorformat^=%+Gmake%.%#                 " Remove makefile errors from error jump list
set errorformat^=%-GIn\ file\ included\ %.%# " General ignore format
set expandtab                                "
set foldcolumn=1                             " Makes folds visable in the sidebar
set foldlevel=2                              "
set foldmethod=indent                        " Allows indented code folding
set foldnestmax=10                           "
" set grepprg=grep\ -rn\                     " Set default :grep program
set hidden                                   " Allow buffer switching without saving
set history=1000                             " Sets how many lines of history VIM has to remember
set hlsearch                                 " Highlight search
set ignorecase                               " Ignore case in searches
set incsearch                                " Incremental search
set lazyredraw                               " Don't redraw the screen during application of macros
set list                                     " This and the above expose whitespace characters
set listchars=tab:o—,nbsp:_,trail:–          " Exposes whitespace characters
set modelines=0                              " CVE-2007-2438
set mouse=a                                  " Enable mouse support in all modes
set nofixendofline                           " Do not add or remove final end of line
set nofoldenable                             "
set nrformats+=alpha                         " Make letters increment and decrement able
                                             " TODO(tlc): See if this is still needed
set number                                   " Enable line numbers at startup
set numberwidth=1                            " Minimum number of columns to use fo line numbers
set path+=**                                 " Used for nested file searching
" set printoptions=number:y                  " Adds numbers to :hardcopy command
set scrolloff=5                              " Keep at least 5 lines above and below the cursor
set shiftwidth=4                             " Set the shift width; amount of space characters
set signcolumn=number                        " Put signs in the number column instead of sign column
set smartcase                                " Excepted proper casing if an uppercase letter is used
set softtabstop=4                            "
set spelllang=en_us                          "
set tabstop=4                                "
set tags+=/usr/local/include/tags            "
set undodir=~/.vim/undodir                   " Directory to vim undo files
set undofile                                 " Maintain undo history between sessions
set updatetime=300                           " Faster refresh rate
set wildmenu                                 " Show tab completion options

" ============================================================================
" ░█░█░▀█▀░█▀▀░█░█░█░░░▀█▀░█▀▀░█░█░▀█▀░▀█▀░█▀█░█▀▀
" ░█▀█░░█░░█░█░█▀█░█░░░░█░░█░█░█▀█░░█░░░█░░█░█░█░█
" ░▀░▀░▀▀▀░▀▀▀░▀░▀░▀▀▀░▀▀▀░▀▀▀░▀░▀░░▀░░▀▀▀░▀░▀░▀▀▀
" Highlighting ===============================================================
" Cursor, Color, and Style related settings.
"
" TODO(tlc): Figure out what 'term=NONE' was suppose to be doing and remove if
"            it's not important.
hi CocCodeLens      term=NONE ctermbg=NONE       ctermfg=darkyellow cterm=bold guibg=darkgrey
hi CocHighlightText term=NONE ctermbg=236        ctermfg=NONE       cterm=bold
hi ColorColumn      term=NONE ctermbg=236        ctermfg=NONE       cterm=NONE
hi CursorLine       term=NONE ctermbg=236        ctermfg=NONE       cterm=NONE
hi DebugPC          term=NONE ctermbg=236        ctermfg=darkyellow cterm=bold
"hi DiffAdd          term=NONE ctermbg=17         ctermfg=10         cterm=bold guibg=Red guifg=bg gui=none
"hi DiffChange       term=NONE ctermbg=17         ctermfg=10         cterm=bold guibg=Red guifg=bg gui=none
"hi DiffDelete       term=NONE ctermbg=17         ctermfg=10         cterm=bold guibg=Red guifg=bg gui=none
"hi DiffText         term=NONE ctermbg=88         ctermfg=10         cterm=bold guibg=Red guifg=bg gui=none
hi FoldColumn       term=NONE ctermbg=NONE       ctermfg=darkyellow cterm=bold guibg=darkgrey
hi Folded           term=NONE ctermbg=black      ctermfg=darkblue   cterm=bold
hi Pmenu            term=NONE ctermbg=236        ctermfg=15         guibg=magenta
hi Search           term=NONE ctermbg=yellow     ctermfg=black      cterm=bold
hi SignColumn       term=NONE ctermbg=black      ctermfg=darkyellow cterm=bold guibg=darkgrey
hi SpecialKey       term=NONE ctermbg=red        ctermfg=black      cterm=bold guibg=darkgrey
hi SpellBad         term=NONE ctermbg=NONE       ctermfg=darkred    cterm=reverse
hi Todo             term=NONE ctermbg=NONE       ctermfg=green      cterm=bold
hi VertSplit        term=NONE ctermbg=NONE       ctermfg=white      cterm=NONE
hi Visual           term=NONE ctermbg=darkyellow ctermfg=black      cterm=bold
hi Whitespace       term=NONE ctermbg=NONE       ctermfg=235        cterm=NONE

" ============================================================================
" ░█▀█░█░█░▀█▀░█▀█░█▀▀░█▄█░█▀▄
" ░█▀█░█░█░░█░░█░█░█░░░█░█░█░█
" ░▀░▀░▀▀▀░░▀░░▀▀▀░▀▀▀░▀░▀░▀▀░
" Autocmd ====================================================================
" Everything below registers into this group; clearing it first keeps
" :source $MYVIMRC from stacking duplicate autocommands.
augroup vimrc
    autocmd!
augroup END

au vimrc WinEnter * setlocal cursorline
au vimrc WinLeave * setlocal nocursorline

" Set 2 space indentation for certain file formats.
au vimrc FileType html,css,javascript,javascriptreact,typescript,typescriptreact,json,vue,xml,xsl setlocal tabstop=2 softtabstop=2 shiftwidth=2

" Set syntax highlighting for misc. C++-like file extensions.
au vimrc BufEnter *.tpp :setlocal filetype=cpp

" Specify filetypes that should use tabs instead of spaces.
au vimrc FileType make setlocal noexpandtab

" Set Rmarkdown render command
au vimrc Filetype rmd map <silent> <leader>rr :!echo<space>"require(rmarkdown);<space>render('<C-r>%')"<space>\|<space>R<space>--vanilla<enter>

" File templates =============================================================
" TODO(tlc): Make automatic include guards for header files.
au vimrc BufNewFile *.c,*.cpp,*.h,*.hpp so ~/.vim/templates/cxx_source.txt
au vimrc BufNewFile *.c,*.cpp,*.h,*.hpp exe "1," . 8 . "g/@file.*/s//@file " .expand("%")
au vimrc BufNewFile *.c,*.cpp,*.h,*.hpp exe "1," . 8 . "g/@version.*/s//@version " .strftime("0.0.%y%j%H%M")
au vimrc BufNewFile *.c,*.cpp,*.h,*.hpp exe "1," . 8 . "g/@date.*/s//@date " .strftime("%Y-%m-%dT%H:%M:%SZ%z (%A)")
au vimrc BufNewFile *.c,*.cpp,*.h,*.hpp exe "normal G"
au vimrc BufNewFile *.md so ~/.vim/templates/md_frontmatter.txt

" ============================================================================
" ░█▄█░█▀█░█▀█░█▀█░▀█▀░█▀█░█▀▀░█▀▀
" ░█░█░█▀█░█▀▀░█▀▀░░█░░█░█░█░█░▀▀█
" ░▀░▀░▀░▀░▀░░░▀░░░▀▀▀░▀░▀░▀▀▀░▀▀▀
" Mappings ===================================================================
" Set <leader> to <space>.
let mapleader=" "

" Open split files vertically.
noremap <C-w>gf <C-w>vgf

" Remove search highlighting till next search.
nnoremap <silent> <leader><esc> :noh<CR>

" Use visual selection for search and replace.
vnoremap <C-r> "hy:%s/<C-r>h//g<left><left>

" Ripgrep search for visually selected.
vnoremap <silent> <leader>s y:Rg <C-r>"<CR>

" Search current file for visually selected
vnoremap <silent> <leader>/ y/\V<C-R>=escape(@",'/\')<CR><CR>

" Support tab and shift-tab for indenting and unindenting.
vnoremap <silent> <tab> >gv
vnoremap <silent> <S-tab> <gv

" Fetch the url on the current line with curl.
nnoremap <leader>cu !!xargs curl -v<CR>

" Create a vertical split with a terminal buffer in it.
" NOTE: You can't map CTRL-` because it equates to a NUL chararcter and vim
" will always interperate it as such.
nnoremap <silent> <leader>` :vs<CR>:term<CR>a

" Open the symbol outline (coc).
nnoremap <silent> <leader>T :<C-u>CocList outline<CR>

" Compile latex (.tex) documents from normal mode.
nnoremap <silent> <leader>l :w<CR>:!pdflatex %; xdg-open %:t:r.pdf<CR>

" Accept the coc completion menu with Tab when it is open, otherwise insert a tab.
" <C-n>/<C-p> move through the menu, <C-y> also accepts, <C-e> cancels.
inoremap <silent><expr> <TAB> coc#pum#visible() ? coc#pum#confirm() : "\<Tab>"

" Trigger Codi scratchpad.
nnoremap <silent> <leader>is :Codi!!<CR>

" Allow gf to open non-existing files.
nmap gf :e <cfile><CR>

" Place fill character.
nmap <C-h> i{{#}}<esc>

" Start fuzzy file search
nnoremap <C-p> :Files<CR>

" Start fuzzy text search
nnoremap <leader><C-f> :Rg<CR>

" Move to next fill character, stay in insert mode, and remove highlight.
inoremap <C-h> <esc>/{{#}}<CR>:noh<CR>"_c4l

" Line break at cursor.
nmap <silent> <leader><leader> i<CR><esc>

" Place blank line below. (stays in normal mode)
nmap <silent> <leader>o o<esc>

" Place blank line above. (stays in normal mode)
nmap <silent> <leader>O O<esc>

" List available buffers
nnoremap <silent> <leader>b :ls<CR>:b<space>

" Make the current file into a pdf.
nnoremap <silent> <leader>pd :w<CR>:ha>%.ps<CR>:!ps2pdf %.ps && rm %.ps<CR>

" Autocorrect next misspelled word.
nnoremap <silent> <leader>z ]s1z=

" Autocorrect previous misspelled word.
nnoremap <silent> <leader>Z [s1z=

" Go to the next buffer
nnoremap <silent> <tab> :bn<CR>

" Go to the previous buffer
nnoremap <silent> <S-tab> :bp<CR>

" Close all but the current buffer.
command CloseAllButCurrent silent! execute "%bd|e#|bd#"
nnoremap <silent> <leader>dd :CloseAllButCurrent<CR>

" Visually select last changed or put text.
nnoremap gp `[v`]

" Switch to corresponding header/source file.
nnoremap <silent> <leader>e :CocCommand clangd.switchSourceHeader<CR>

" Jump to next item in quickfix.
nnoremap <silent> <expr> <C-j> &diff ? ']c' : ':cn<CR>'

" Jump to previous item in quickfix.
nnoremap <silent> <expr> <C-k> &diff ? '[c' : ':cprev<CR>'

" VimGrep the open buffers
nnoremap <silent> <leader>v :GrepBufs<C-l><space>

" VimGrep the word under the cursor within the open buffers.
nnoremap <silent> <leader>V :call GrepBuffers("<C-R><C-W>")<CR>

" diff mode mappings
if &diff
    map <leader>1 :diffget LOCAL<CR>
    map <leader>2 :diffget BASE<CR>
    map <leader>3 :diffget REMOTE<CR>
endif

" Open fuzzy file browser
nnoremap <silent> <leader>4 :Files<CR>

" Repeat last entered colon command
nnoremap <silent> <leader>; @:

" Automatically format current buffer
nnoremap <silent> <F2> :call CocActionAsync('format')<CR>

" With AsyncRun plugin ------------------------------------------------------
" Run :make asynchronously
nnoremap <silent> <leader>m :wa<CR>:AsyncRun :silent make<CR>:copen<CR><C-w>p
" Run :make asynchronously with 6 threads
nnoremap <silent> <leader>M :wa<CR>:AsyncRun :silent make -j6<CR>:copen<CR><C-w>p
" Run :make clean asynchronously.
nnoremap <silent> <F4> :wa<CR>:AsyncRun :silent make clean<CR>:copen<CR><C-w>p
" Run :make asynchronously and open the Quickfix menu.
nnoremap <silent> <F9> :wa<CR>:AsyncRun :silent make rebuild<CR>:copen<CR><C-w>p
" Run the current script file asynchronously (must have shebang)
nnoremap <silent> <leader>C :AsyncRun "%<CR>

" Run an a.out program.
nnoremap <silent> <F5> :term a.*<CR>

" Run a command line command in a file.
nnoremap <silent> <leader>rc yy:vs<CR>:exec 'term '.@"<CR>
vnoremap <silent> <leader>rc y:vs<CR>:exec 'term '.@"<CR>

" Toggle line number modes
nnoremap <silent> <leader>n :call g:ToggleNuMode()<CR>

" Open/close Quickfix drawer.
nnoremap <silent> <leader>q :call g:ToggleQuickfix()<CR>

" Toggle spell mode.
nnoremap <silent> <leader>s :setlocal spell!<CR>

" Toggle whitespace (list) setting.
nnoremap <silent> <leader>u :set list!<CR>

" Open and close project drawer, uses :Lexplore if there is no NERDTree.
nmap <silent> <leader><tab> :call g:ToggelFileBrowser()<cr>

" Execute a macro over a visually selected range.
xnoremap @ :<C-u>call ExecuteMacroOverVisualRange()<CR>

" Toggle Markdown Preview
nmap <leader>pm <Plug>MarkdownPreviewToggle

" Escape terminal command insert mode
tnoremap <esc> <C-\><C-n>

" Start EasyAlign in normal mode and visual mode.
nmap ga <Plug>(EasyAlign)
xmap ga <Plug>(EasyAlign)

" Mouse Mappings
nnoremap <silent> <C-LeftMouse> <LeftMouse>:call SmartCtrlClick()<CR>

" ============================================================================
" ░█▀▀░█░█░█▀█░█▀▀░▀█▀░▀█▀░█▀█░█▀█░█▀▀
" ░█▀▀░█░█░█░█░█░░░░█░░░█░░█░█░█░█░▀▀█
" ░▀░░░▀▀▀░▀░▀░▀▀▀░░▀░░▀▀▀░▀▀▀░▀░▀░▀▀▀
" Functions ==================================================================
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

function! SmartCtrlClick()
  let l:cfile = expand('<cfile>')
  if filereadable(l:cfile)
    " It's a file => open it
    execute 'edit ' . fnameescape(l:cfile)
  else
    " Not a file => treat it as a symbol => go to definition
    normal! gd
  endif
endfunction

" ============================================================================
" ░█▀█░█░░░█░█░█▀▀░▀█▀░█▀█░█▀▀
" ░█▀▀░█░░░█░█░█░█░░█░░█░█░▀▀█
" ░▀░░░▀▀▀░▀▀▀░▀▀▀░▀▀▀░▀░▀░▀▀▀
" Plugins ====================================================================
"" Plugins install with packadd ______________________________________________
" Built-in commenting (gc / gcc), replaces vim-commentary.
packadd! comment

" Termdebug ==================================================================
packadd! termdebug

" Termdebug ==================================================================
" Evaluate the expression under the cursor, you can also use K by default or
" use balloon_eval on hover.
au vimrc User TermdebugStartPost nnoremap <RightMouse> :Evaluate<CR>
au vimrc User TermdebugStopPost silent! nunmap <RightMouse>

" Start vim terminal debugger (gdb), load a.out if it exists, set cursor to
" bottom of output pane so that it will follow the output properly.
nnoremap <silent> <F8> :Termdebug a.out<CR>avimdb<CR><C-\><C-n><C-w>wG<C-w>pa

" Set window layout for Termdebug
let g:termdebug_wide=1

"" Plugins installed with vimplug.
" COC.nvim ===================================================================
" Disable python2 support, python2 is deprecated.
let g:loaded_python_provider = 0

" Extensions
let g:coc_global_extensions = [
    \ '@yaegassy/coc-volar',
    \ '@yaegassy/coc-volar-tools',
    \ 'coc-clangd',
    \ 'coc-css',
    \ 'coc-docker',
    \ 'coc-eslint',
    \ 'coc-git',
    \ 'coc-go',
    \ 'coc-html',
    \ 'coc-json',
    \ 'coc-markdownlint',
    \ 'coc-prettier',
    \ 'coc-pyright',
    \ 'coc-sh',
    \ 'coc-tsserver',
    \ 'coc-yaml',
    \ ]

" Highlight the symbol and its references on cursor hover.
au vimrc CursorHold * if exists('*CocActionAsync') | silent call CocActionAsync('highlight') | endif
inoremap <C-s> <C-r>=CocActionAsync('showSignatureHelp')<CR>

" Always show the signcolumn, otherwise it would shift the text each time
" diagnostics appear/become resolved.
if has("patch-8.1.1564")
    " Recently vim can merge signcolumn and number column into one
    set signcolumn=number
else
    set signcolumn=yes
endif

" Use leader+K to show documentation in preview window.
nnoremap <silent> <leader>K :call <SID>show_documentation()<CR>

function! s:show_documentation()
    if (index(['vim','help'], &filetype) >= 0)
        execute 'h '.expand('<cword>')
    elseif (coc#rpc#ready())
        call CocActionAsync('doHover')
    else
        execute '!' . &keywordprg . " . expand('<cword>')"
    endif
endfunction

" Jump to next and previous issue
nmap <silent> <leader>a <Plug>(coc-diagnostic-next-error)
nmap <silent> <leader>x <Plug>(coc-diagnostic-previous-error)
nmap <silent> <leader>A <Plug>(coc-diagnostic-next)
nmap <silent> <leader>X <Plug>(coc-diagnostic-previous)

" Formatting
nmap <silent> <leader>fm <Plug>(coc-format)
nmap <silent> <leader>fl <Plug>(coc-format-selected)
xmap <silent> <leader>fl <Plug>(coc-format-selected)

" Symbol navigation
nmap <silent> <leader>dj :<C-u>CocCommand document.jumpToNextSymbol<CR>
nmap <silent> <leader>dk :<C-u>CocCommand document.jumpToPrevSymbol<CR>

" Symbol renaming.
nmap <leader>rn <Plug>(coc-rename)
nmap <leader>rf <Plug>(coc-refactor)

" List code actions
nmap <leader>ra <Plug>(coc-codeaction)

" GoTo code navigation.
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

" Run the codelens action on the current line
nmap <silent> <leader>cl <Plug>(coc-codelens-action)

" Add `:Format` command to format current buffer.
command! -nargs=0 Format :call CocAction('format')

" Add `:Fold` command to fold current buffer.
command! -nargs=? Fold :call CocAction('fold', <f-args>)

" Add `:OR` command for organize imports of the current buffer.
command! -nargs=0 OR   :call CocAction('runCommand', 'editor.action.organizeImport')

" Add `:Prettier` command to format the current buffer with coc-prettier.
command! -nargs=0 Prettier :CocCommand prettier.forceFormatDocument

" Mapping for CocList
" Show all diagnostics.
nnoremap <silent><nowait> <leader>da :<C-u>CocList diagnostics<CR>

" Manage extensions.
nnoremap <silent><nowait> <leader>cx :<C-u>CocList extensions<CR>

" Show commands.
nnoremap <silent><nowait> <leader>cm :<C-u>CocList commands<CR>

" Find symbol of current document.
nnoremap <silent><nowait> <leader>co :<C-u>CocList outline<CR>

" Search airspace symbols.
nnoremap <silent><nowait> <leader>cw :<C-u>CocList -I symbols<CR>

" Misc. Mappings
" Do default action for next item.
nnoremap <silent><nowait> <leader>cn :<C-u>CocNext<CR>

" Do default action for previous item.
nnoremap <silent><nowait> <leader>cp :<C-u>CocPrev<CR>

" Resume fastest coc list.
nnoremap <silent><nowait> <leader>re :<C-u>CocListResume<CR>

" Open coc-yank list
nnoremap <silent> <leader>yl :<C-u>CocList -A yank<CR>

" NERDTree ===================================================================
let g:NERDTreeShowHidden = 1
let g:NERDTreeQuitOnOpen = 1
let g:NERDTreeMinimalUI = 1 " hide helper, this also hides ".." (use 'u')
let g:NERDTreeIgnore = ['^node_modules$']
let g:NERDTreeStatusline = '' " set to empty to use lightline

" Close window if NERDTree is the last one
au vimrc BufEnter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif

" Map to open current file in NERDTree and set size
nnoremap <leader>pv :NERDTreeFind<bar> :vertical resize 45<CR>

" Airline ====================================================================
" Set the theme for airline.
" let g:airline_theme='luna'
" let g:airline_theme = 'base16_grayscale'
let g:airline_theme = 'minimalist'
" let g:airline_theme = 'monochrome'
let g:airline#extensions#branch#enabled = 1
let g:airline#extensions#hunks#enabled = 1
let g:airline#extensions#tabline#buffer_nr_show = 1
let g:airline#extensions#tabline#enabled = 1
let g:airline_powerline_fonts = 1
if !exists('g:airline_symbols')
    let g:airline_symbols = {}
endif

" ----------------------------------------------------------------------------
" NOTE(tlc): If you cant see some of the following symbols then either your
"            terminal doesn't render them or your font doesn't support them.
"            Try using a different terminal and if it still doesn't work then
"            its your font and you need to install a font that supports
"            powerline fonts. Try a font from the NerdFonts collection of
"            patched fonts. Otherwise, uncomment the fonts symbols that aren't
"            broken below.
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
" let g:airline_symbols.spell = ''
let g:airline_symbols.notexists = 'Ɇ'
let g:airline_symbols.whitespace = '∥'

let g:airline_symbols.maxlinenr = 'Ξ'
let g:airline_symbols.dirty = '⚡'


" LimeLight ==================================================================
" Color name (:help cterm-colors) or ANSI code
" let g:limelight_conceal_ctermfg = 'gray'
let g:limelight_conceal_ctermfg = 240

" Color name (:help gui-colors) or RGB color
" let g:limelight_conceal_guifg = 'DarkGray'
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
au vimrc User GoyoEnter Limelight
au vimrc User GoyoLeave Limelight!

let g:goyo_width = 100

" Vim-Cpp-Enhanced-Highlight =================================================
let g:cpp_class_scope_highlight = 1
let g:cpp_member_variable_highlight = 1
let g:cpp_class_decl_highlight = 1
let g:cpp_posix_standard = 1
"let g:cpp_experimental_simple_template_highlight = 1
let g:cpp_experimental_template_highlight = 1   " Faster than above
let g:cpp_concepts_highlight = 1
"let g:cpp_no_function_highlight = 1

" fzf ========================================================================
" Use ripgrep to list files for :Files (respects .gitignore, shows dotfiles).
let $FZF_DEFAULT_COMMAND = 'rg --files --hidden --glob "!.git"'
let g:fzf_action = {'ctrl-t': 'tab split', 'ctrl-s': 'split', 'ctrl-v': 'vsplit'}

" GitGutter ==================================================================
hi GitGutterAdd ctermfg=green ctermbg=black guifg=#009900
hi GitGutterChange ctermfg=yellow ctermbg=black guifg=#bbbb00
hi GitGutterDelete ctermfg=red ctermbg=black guifg=#ff2222

" DirDiff ====================================================================
nnoremap <silent> <leader>dn :DirDiffNext<CR>
nnoremap <silent> <leader>dp :DirDiffPrevious<CR>

" Markdown-Preview ===========================================================
let g:mkdp_auto_close = 1
let g:mkdp_browser = 'firefox'
let g:mkdp_echo_preview_url = 1
let g:mkdp_page_title = 'Preview 「${name}」'

" ============================================================================
" Plugins will be downloaded under the specified directory.
call plug#begin('~/.vim/plugged')

" NOTE(tlc): Anything to do with tags and language servers in specific require
"            configuration. Be sure that they are properly configured or they
"            wont work.  Other plugins that are commented out here are things
"            I use only on occasion to better fit the work I am doing.
"            (non-code based writing).

" Declare the list of plugins
Plug 'Matt-A-Bennett/vim-surround-funk'                                 " Surround function calls
" Plug 'SirVer/ultisnips'                                               " {{#}}
Plug 'airblade/vim-gitgutter'                                           " Git diff in the gutter
Plug 'andymass/vim-matchup'                                             " Extends % key to language-specific words
Plug 'ap/vim-css-color'                                                 " Add css color previews
Plug 'chaoren/vim-wordmotion'                                           " Move by camalCase and snake_case
" Plug 'godlygeek/tabular'                                              " Text Alignment, through {{#}}
Plug 'iamcco/markdown-preview.nvim', { 'do': 'cd app && yarn install' } " Preview markdown files
Plug 'jiangmiao/auto-pairs'                                             " Autocomplete scopes and more
" Plug 'windwp/nvim-autopairs'                                          " replaces auto-pairs
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }                     " Fuzzy searching of files
Plug 'junegunn/fzf.vim'                                                 " ^
Plug 'junegunn/goyo.vim'                                                " Minimal interface
Plug 'junegunn/limelight.vim'                                           " Dims unfocused text sections
Plug 'junegunn/vim-easy-align'                                          " Text Alignment, simple
" Plug 'ludovicchabant/vim-gutentags'                                   " Provides tag management
Plug 'mattn/emmet-vim'                                                  " Web code abbreviation tool
Plug 'metakirby5/codi.vim'                                              " Interactive scratchpad
Plug 'mhinz/vim-startify'                                               " Add vim home screen
Plug 'mtdl9/vim-log-highlighting'                                       " Highlighting for log files
Plug 'neoclide/coc.nvim', {'branch': 'release'}                         " Completion engine, primary
Plug 'octol/vim-cpp-enhanced-highlight'                                 " C++ syntax highlighting
" Plug 'puremourning/vimspector'                                        " Vim graphical debugger {{#}}
Plug 'preservim/nerdtree'                                               " File browser
Plug 'skywind3000/asyncrun.vim'                                         " Run commands asynchronously
" Plug 'skywind3000/gutentags_plus'                                     " Extends gutentags capabilities
Plug 'tpope/vim-fugitive'                                               " Git integration
" Plug 'adelarsq/vim-matchit'                                           " Repo for matchit.vim, replaced by matchup
Plug 'tpope/vim-repeat'                                                 " Repeat commands
Plug 'tpope/vim-surround'                                               " Surround text objects
Plug 'vim-airline/vim-airline'                                          " Adds styled status bars
Plug 'vim-airline/vim-airline-themes'                                   " Themes for airline
Plug 'will133/vim-dirdiff'                                              " Diff whole directories

" Lue Plugins ================================================================
" Plug 'danymat/neogen'                       " Annotation toolkit
" Plug 'nvim-treesitter/nvim-treesitter'      " Interface to tree-sitter parser generator

" List ends here. Plugins become visible to Vim after calling plug#end()
call plug#end()
