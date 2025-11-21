require("nvim-treesitter.configs").setup({
	ensure_installed = { "python", "lua", "bash", "vim", "c" },
	highlight = {
		enable = true,
		additional_vim_regex_highlighting = false,
	},
})

