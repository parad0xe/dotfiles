-- https://github.com/akinsho/toggleterm.nvim

require("toggleterm").setup({
	size = function(term)
		local lines = vim.o.lines
		local height = math.floor(lines * 0.25)
		if height < 8 then height = 8 end
		if height > 20 then height = 20 end
		return height
    end,
    direction = "horizontal",
	persist_size = false,
	persist_mode = false,
    hide_numbers = true,
    shade_filetypes = {},
    shade_terminals = false,
    start_in_insert = true,
    close_on_exit = true,
})

-- open terminal
keymap("n", "<C-t>", ":ToggleTerm<CR>", opts)

-- close terminal
keymap("t", "<C-t>", "<C-\\><C-n>:ToggleTerm<CR>", opts)

-- switch mode: normal -> terminal
keymap("n", "<C-n>", "i", opts)

-- switch mode: terminal -> normal
keymap("t", "<C-n>", "<C-\\><C-n>", opts)
