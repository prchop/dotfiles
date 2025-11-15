local telescope = require("telescope")
telescope.setup({
	defaults = {
		pickers = {
			find_files = {
				theme = "",
			},
		},
		prompt_prefix = "   ",
		selection_caret = " ❯ ",
		entry_prefix = "   ",
		multi_icon = "+ ",
		path_display = { "filename_first" },
		vimgrep_arguments = {
			"rg",
			"--color=never",
			"--no-heading",
			"--with-filename",
			"--line-number",
			"--column",
			"--smart-case",
			"--sort=path",
		},
    layout_strategy = "horizontal",
    layout_config = {
      width = 0.95,
      height = 0.95,
      preview_width = 0.6,
      preview_cutoff = 0,
    },
  },
})
