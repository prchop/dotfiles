vim.opt.runtimepath:prepend(vim.env.HOME .. "/.vim")
vim.opt.runtimepath:append(vim.env.HOME .. "/.vim/after")
vim.opt.packpath = vim.opt.runtimepath:get()

vim.cmd("source ~/.vimrc")

vim.cmd([[
  highlight Normal guibg=NONE
  highlight NonText guibg=NONE
  highlight Status guibg=NONE
  "highlight WinBar guibg=#303030
]])

vim.fn.sign_define("DiagnosticSignError", { text = "🔥", texthl = "DiagnosticError" })
vim.fn.sign_define("DiagnosticSignWarn", { text = "❗️", texthl = "DiagnosticWarn" })
vim.fn.sign_define("DiagnosticSignInfo", { text = "✨", texthl = "DiagnosticInfo" })
vim.fn.sign_define("DiagnosticSignHint", { text = "💡", texthl = "DiagnosticHint" })

-- Set cursor highlight with background color
vim.cmd("highlight Cursor guibg=#928374 guifg=NONE")

---- Set the statusline
--vim.opt.statusline = "%f %m %r %= %y %l:%c %p%%"

-- local screenkey_available = vim.fn.has("nvim-0.8") == 1
local is_nvim_compatible = vim.fn.has("nvim") == 1 and vim.version().major >= 0 and vim.version().minor >= 8
local screenkey_available = is_nvim_compatible
	and vim.fn.getenv("NVIM_SCREENKEY") ~= nil
	and pcall(require, "screenkey")

if screenkey_available then
	vim.g.screenkey_statusline_component = true
	vim.o.winbar = "%= %{%v:lua.require('screenkey').get_keys()%} %="
	vim.api.nvim_set_keymap("n", "<leader>sc", ":Screenkey<CR>", { noremap = true, silent = true })
	require("screenkey").setup({
		win_opts = {
			width = 100,
		},
	})
end

