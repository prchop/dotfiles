local harpoon = require("harpoon")
harpoon:setup()

vim.keymap.set("n", "<leader>ha", function()
	harpoon:list():add()
end)

vim.keymap.set("n", "<leader>hl", function()
	harpoon.ui:toggle_quick_menu(harpoon:list())
end)

-- Set <leader>1..<leader>6 to navigate to specific files in harpoon list
for _, idx in ipairs({ 1, 2, 3, 4, 5, 6 }) do
	vim.keymap.set("n", string.format("<leader>%d", idx), function()
		harpoon:list():select(idx)
	end)
end
