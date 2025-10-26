-- Additional treesitter configuration via autocmds
-- Place this in: ~/.config/nvim/lua/config/autocmds.lua (append to your existing file)
-- Or create: ~/.config/nvim/lua/plugins/treesitter-extras.lua

-- Register htmldjango filetype with html treesitter parser
vim.treesitter.language.register("html", "htmldjango")

-- Fix for Python f-strings - reparse when entering Python files
vim.api.nvim_create_autocmd("FileType", {
	pattern = "python",
	callback = function()
		local parser = vim.treesitter.get_parser(0, "python")
		if parser then
			parser:parse()
		end
	end,
	desc = "Reparse Python buffer for f-strings",
})

-- Better folding with treesitter
vim.api.nvim_create_autocmd("FileType", {
	pattern = "*",
	callback = function()
		-- Only set if treesitter is available for this filetype
		local has_ts = pcall(vim.treesitter.get_parser, 0)
		if has_ts then
			vim.opt_local.foldmethod = "expr"
			vim.opt_local.foldexpr = "v:lua.vim.treesitter.foldexpr()"
			vim.opt_local.foldenable = false -- Don't fold by default
		end
	end,
	desc = "Setup treesitter folding",
})

return {}
