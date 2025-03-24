return {
	{
		"williamboman/mason.nvim",
		opts = {
			ensure_installed = {
				"prettierd",
				-- python
				"isort",
				"black",
				-- lua
				"stylua",
				"selene",
				"luacheck",
				-- json
				"json-lsp",
				-- yaml
				"yamllint",
				"yaml-language-server",
				"yamlfmt",
				"yamlfix",
				-- markdown
				"markdownlint-cli2",
				"markdown-toc",
				-- shell
				"shellcheck",
				"shfmt",
				"bash-language-server",
				-- matlab
				"matlab-language-server",
				-- xml
				"xmlformatter",
			},
		},
	},
}
