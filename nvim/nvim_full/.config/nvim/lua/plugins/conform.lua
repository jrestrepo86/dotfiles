return {
	{
		"stevearc/conform.nvim",
		opts = {
			formatters_by_ft = {
				python = { "isort", "black" },
				css = { "prettier" },
				scss = { "prettier" },
				html = { "prettier" },
				json = { "prettier" },
				yaml = { "yamlfmt" },
				markdown = { "prettier" },
				htmldjango = { "djhtml" },
				tex = { "latexindent" },
				dockerfile = { "hadolint" },
				lua = { "luaformatter" },
				sql = { "sql-formatter" },
				xml = { "xmlformatter" },
			},
		},
	},
}
