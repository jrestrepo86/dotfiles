return {
	{
		"stevearc/conform.nvim",
		opts = {
			formatters_by_ft = {
				python = { "ruff_fix", "ruff_organize_imports", "ruff_format" },
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
