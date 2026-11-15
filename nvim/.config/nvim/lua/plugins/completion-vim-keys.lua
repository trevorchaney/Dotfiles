-- Completion behavior (blink.cmp, overriding LazyVim defaults):
--   <C-n>/<C-p>  next/previous item
--   <Tab>        accept, only when the menu is open (otherwise snippet jump / normal tab)
--   <CR>         always a plain newline, never accepts
--   <C-e>        dismiss menu
--   <C-space>    open menu / docs
--
-- The menu also stays hidden when its only suggestion is exactly the word
-- you've already typed (unless you opened it yourself with <C-space>).

-- True when the list holds a single item identical to the typed keyword.
local function only_exact_match(ctx, items)
	if #items ~= 1 or ctx.trigger.initial_kind == "manual" then
		return false
	end
	local keyword = ctx.get_keyword()
	return keyword ~= "" and items[1].label == keyword
end

return {
	"saghen/blink.cmp",
	opts = {
		keymap = {
			preset = "super-tab",
			["<C-n>"] = { "select_next", "fallback" },
			["<C-p>"] = { "select_prev", "fallback" },
		},
		completion = {
			menu = {
				auto_show = function(ctx, items)
					if only_exact_match(ctx, items) then
						-- The menu may already be open from a shorter prefix; close it.
						vim.schedule(function()
							require("blink.cmp").hide()
						end)
						return false
					end
					return true
				end,
			},
		},
	},
}
