local base_dir = "$GHREPOS"
require("zettelkasten").setup({
	notes_path = vim.fn.expand(base_dir) .. "/zett-notes/notes",
	browseformat = "%d - %h [%r Refs] [%b B-Refs] %t",
})

-- Fix Shif+K in kbrowse
vim.api.nvim_create_autocmd("FileType", {
	pattern = { "zkbrowser" },
	callback = function()
		vim.keymap.set("n", "K", function()
			local word = vim.fn.expand("<cword>")
			-- Wrap vim.cmd in a function for pcall
			local success = pcall(function()
				vim.cmd(":ZkHover -preview")
			end)
			-- If ZkHover fails, execute ltag
			if not success then
				vim.cmd(":ltag " .. vim.fn.escape(word, " \\"))
			end
		end, { buffer = true })
	end,
})

-- For update the tags
if vim.fn.executable("ctags") == 1 then
	vim.api.nvim_create_user_command(
		"ZkUpTags",
		"!cd "
			.. base_dir
			.. " && ctags -R --langdef=markdowntags --languages=markdowntags --langmap=markdowntags:.md --kinddef-markdowntags=t,tag,tags --mline-regex-markdowntags='/(^|[[:space:]])\\#(\\w\\S*)/\\2/t/{mgroup=1}' -f tags .",
		{
			range = false,
		}
	)
end

-- For pull notes location on github
vim.api.nvim_create_user_command("ZkPGit", function(args)
	local github_username = "$USER"
	if args["args"] and string.len(args["args"]) > 0 then
		vim.cmd(
			"silent !xdg-open https://github.com/"
				.. github_username
				.. "/zett-notes/tree/main/notes/"
				.. args["args"]
				.. ".md  > /dev/null 2>&1 &"
		)
	else
		vim.notify(
			"ZkPGit: Missing note ID. Please provide a valid ID.",
			vim.log.levels.ERROR,
			{ title = "ZkPGit Error" }
		)
	end
end, { nargs = "*" })
