-- disable netrw at the very start of your init.lua
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
vim.opt.termguicolors = true

require('config.globals')

-- Navigation
require('config.navigation.nvim-tree')
require('config.navigation.telescope')

-- Code
require('config.code.package-manager')
require('config.code.lsp')
require('config.code.linter')
require('config.code.format')
require('config.code.goto-preview')
require('config.code.docstring')
require('config.code.completion')

-- Appearance
require('config.appearance.theme')
require('config.appearance.cursor')
require('config.appearance.statusbar')
require('config.appearance.animations')

-- Tools
require('config.tools.terminal')

keymap("n", "<C-q>", function()
    vim.cmd("close")
    editor_focus()
end, { desc = "Smart close window" })

keymap("n", " lg", "<cmd>LazyGit<cr>", { desc = "Open lazygit window" })
keymap("n", " mt", "<cmd>MarkdownPreviewToggle<cr>", { desc = "Toggle markdown preview in browser" })
