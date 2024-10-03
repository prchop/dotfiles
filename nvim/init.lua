-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")
require 'nvim-treesitter.install'.compilers = { 'zig' }
require 'nvim-treesitter.install'.prefer_git = false
