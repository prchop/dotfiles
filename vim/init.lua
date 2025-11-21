vim.opt.runtimepath:prepend(vim.env.HOME .. "/.vim")
vim.opt.runtimepath:append(vim.env.HOME .. "/.vim/after")
vim.opt.packpath = vim.opt.runtimepath:get()

vim.cmd("source ~/.vimrc")

local plugins = {
  "treesitter",
  "gitsigns",
  "harpoon",
  "zettelkasten",
  "telescope",
  "autopairs",
}

if vim.fn.has("nvim-0.10") == 1 then
  for _, plugin in ipairs(plugins) do
    require("plugins." .. plugin)
  end
end

vim.cmd([[
  "colorscheme gruber-darker
  highlight Normal guifg=#d4be98 guibg=NONE
  highlight NonText guibg=NONE
  highlight SpellBad guibg=#1c1c1c guifg=#d70000 gui=NONE
  highlight SpellRare guibg=#1c1c1c guifg=#d70000 gui=NONE
  highlight CursorLine guibg=#282828 guifg=NONE
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

local screenkey_available = vim.fn.has("nvim-0.10") == 1
	and vim.fn.getenv("NVIM_SCREENKEY") ~= nil
	and pcall(require, "screenkey")

if screenkey_available then
  local sckey = require("screenkey")
	vim.o.winbar = "%{%v:lua.require('screenkey').get_keys()%}"
	sckey.setup({
		win_opts = {
			width = 90,
		},
	})
	vim.api.nvim_set_hl(0, "WinBar", { link = "CursorLine" })
	if not sckey.statusline_component_is_active() then
		sckey.toggle_statusline_component()
	end
	vim.api.nvim_set_keymap("n", "<leader>sc",
    ":Screenkey toggle_statusline_component<CR>",
      { noremap = true, silent = true })
end

local opts = { noremap = true, silent = true }
local keymap = vim.keymap.set

-- Additional keymap (telescope)
local builtin = require("telescope.builtin")
vim.keymap.set("n", "<C-p>", function()
	builtin.find_files({
		find_command = {
			"fd",
			"--type",
			"f",
			"--strip-cwd-prefix",
			"--hidden",
			"--exclude",
			"node_modules",
			"--exclude",
			".git",
		},
	})
end, opts)

keymap("n", "<leader>of", function()
	builtin.oldfiles({
		only_cwd = true,
	})
end, opts)

keymap("n", "<leader>lg", function()
	builtin.live_grep()
end, opts)

keymap("n", "<leader>fb", function()
	builtin.buffers()
end, opts)

keymap("n", "<leader>fh", function()
	builtin.help_tags()
end, opts)

keymap("n", "<leader>fc", function()
	builtin.commands()
end, opts)

keymap("n", "<leader>fr", function()
	builtin.resume()
end, opts)

keymap("n", "<leader>fq", function()
	builtin.quickfix()
end, opts)

keymap("n", "<leader>f/", function()
	builtin.current_buffer_fuzzy_find()
end, opts)

--keymap("x", "K", ":move '<-2<CR>gv-gv", opts)
--keymap("x", "J", ":move '>+1<CR>gv-gv", opts)
