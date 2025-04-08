return {
	{
		"stevearc/conform.nvim",
		opts = {
			formatters_by_ft = {
				-- python = { "isort", "black" },
				python = { "ruff_organize_imports", "black" },
				css = { "prettier" },
				scss = { "prettier" },
				html = { "prettier" },
				json = { "prettier" },
				yaml = { "yamlfmt" },
				markdown = { "prettier" },
				htmldjango = { "djlint" },
				tex = { "latexindent" },
				lua = { "stylua" },
				sql = { "sql_formatter" },
				xml = { "xmlformatter" },
			},
		},
	},
}
