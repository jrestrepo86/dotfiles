return {
	{
		"stevearc/conform.nvim",
		opts = {
			formatters_by_ft = {
				python = { "ruff_organize_imports", "ruff_format" },
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
				toml = { "taplo", "pyproject-fmt" },
			},
			-- formatters = {
			-- 	ruff_fix = {
			-- 		args = { "--ignore", "F401" },
			-- 	},
			-- 	ruff_organize_imports = {
			-- 		args = { "--ignore", "F401" },
			-- 	},
			-- },
		},
	},
}
