-- C/C++ language server. The LazyVim clangd extra (enabled in lazyvim.json)
-- provides the setup; this only makes it use the system clangd from
-- pacman (/usr/bin/clangd) instead of downloading a second copy via Mason.
return {
	"neovim/nvim-lspconfig",
	opts = {
		servers = {
			clangd = {
				mason = false,
			},
		},
	},
}
