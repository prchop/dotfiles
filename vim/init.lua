vim.opt.runtimepath:prepend(vim.env.HOME .. "/.vim")
vim.opt.runtimepath:append(vim.env.HOME .. "/.vim/after")
vim.opt.packpath = vim.opt.runtimepath:get()

vim.cmd("source ~/.vimrc")

if vim.fn.has("nvim-0.10") == 1 then
	require("plugins.gitsigns")
	require("plugins.harpoon")
	require("plugins.zettelkasten")
end

vim.cmd([[
  "colorscheme gruber-darker
  highlight Normal guifg=#d4be98 guibg=NONE
  highlight NonText guibg=NONE
  highlight SpellBad guibg=#1c1c1c guifg=#d70000 gui=NONE
  highlight SpellRare guibg=#1c1c1c guifg=#d70000 gui=NONE
  highlight StatusLine guibg=#141414
  highlight CursorLine guibg=#141414 guifg=NONE
]])

vim.diagnostic.config({
	signs = {
		text = {
			[vim.diagnostic.severity.ERROR] = "🔥",
			[vim.diagnostic.severity.WARN] = "❗️",
			[vim.diagnostic.severity.INFO] = "✨",
			[vim.diagnostic.severity.HINT] = "💡",
		},
	},
	virtual_text = true,
	underline = true,
	update_in_insert = false,
	severity_sort = true,
})

-- Set cursor highlight with background color
-- vim.cmd("highlight Cursor guibg=#928374 guifg=NONE")
-- vim.cmd("highlight Cursor guibg=NONE guifg=#2a283e")

---- Set the statusline without background colors
--vim.opt.statusline = "%f %m %r %= %y %l:%c %p%%"

local screenkey_available = vim.fn.has("nvim-0.8") == 1
	and vim.fn.getenv("NVIM_SCREENKEY") ~= nil
	and pcall(require, "screenkey")

if screenkey_available then
	vim.g.screenkey_statusline_component = 1
	vim.o.winbar = "%{%v:lua.require('screenkey').get_keys()%}"
	vim.api.nvim_set_keymap("n", "<leader>sc", ":Screenkey<CR>", { noremap = true, silent = true })
	require("screenkey").setup({
		win_opts = {
			width = 90,
		},
	})
end

require("nvim-treesitter.configs").setup({
	ensure_installed = { "python", "lua", "bash", "vim", "c" },
	highlight = {
		enable = true,
		additional_vim_regex_highlighting = false,
	},
})
