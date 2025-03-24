return {
	{
		"stevearc/conform.nvim",
		opts = {
			formatters_by_ft = {
				python = { "isort", "black" },
				json = { "prettier" },
				yaml = { "yamlfmt" },
				markdown = { "prettier" },
				lua = { "stylua" },
				xml = { "xmlformatter" },
			},
		},
	},
}
