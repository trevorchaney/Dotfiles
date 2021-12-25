set runtimepath^=~/.vim runtimepath+=~/.vim/after
let &packpath = &runtimepath
source ~/.vimrc

" Neovim specific directories
set undodir=~/.config/nvim/undodir  " Directory to neovim undo files.
set backupdir=~/.vim/tmp//,.    " Backup working files to ~/.vim/tmp.
