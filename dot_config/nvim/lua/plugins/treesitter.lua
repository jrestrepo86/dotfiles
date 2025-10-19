return {
	{
		"nvim-treesitter/nvim-treesitter",
		opts = function(_, opts)
			-- add tsx and treesitter
			vim.list_extend(opts.ensure_installed, {
				"bash",
				"vim",
				"regex",
				"c",
				"css",
				"html",
				"tsx",
				"typescript",
				"javascript",
				"json",
				"json5",
				"lua",
				"luadoc",
				"luap",
				"markdown",
				"markdown_inline",
				"python",
				"query",
				"tsx",
				"yaml",
				"latex",
				"ninja",
				"rst",
				"diff",
			})
		end,
	},
}
