vim.opt.runtimepath:prepend(vim.env.HOME .. "/.vim")
vim.opt.runtimepath:append(vim.env.HOME .. "/.vim/after")
vim.opt.packpath = vim.opt.runtimepath:get()

vim.cmd("source ~/.vimrc")

vim.cmd([[
  highlight Normal guibg=NONE
  highlight NonText guibg=NONE
  highlight SpellBad guibg=#1c1c1c guifg=#d70000 gui=NONE
  highlight SpellRare guibg=#1c1c1c guifg=#d70000 gui=NONE
  "highlight WinBar guibg=#303030
]])

-- will be deprecated in nvim 0.12
--vim.fn.sign_define("DiagnosticSignError", { text = "🔥", texthl = "DiagnosticError" })
--vim.fn.sign_define("DiagnosticSignWarn", { text = "❗️", texthl = "DiagnosticWarn" })
--vim.fn.sign_define("DiagnosticSignInfo", { text = "✨", texthl = "DiagnosticInfo" })
--vim.fn.sign_define("DiagnosticSignHint", { text = "💡", texthl = "DiagnosticHint" })

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
vim.cmd("highlight Cursor guibg=#928374 guifg=NONE")

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

-- require harpoon and setup
local harpoon = require("harpoon")
harpoon:setup()

vim.keymap.set("n", "<leader>ha", function()
  harpoon:list():add()
end)
vim.keymap.set("n", "<leader>hl", function()
  harpoon.ui:toggle_quick_menu(harpoon:list())
end)

-- Set <leader>1..<leader>5 to navigate to specific files in harpoon list
for i = 1, 5 do
  vim.keymap.set("n", string.format("<leader>%s", i), function()
    harpoon:list():select(i)
  end)
end
