-- Complete Mason configuration for all languages
-- Python, LaTeX, Bash, Markdown, Docker, YAML, TOML, Django, HTML, CSS, JSON

return {
	{
		"mason-org/mason.nvim",
		opts = function(_, opts)
			-- Remove chktex if LazyVim added it
			opts.ensure_installed = opts.ensure_installed or {}
			local filtered = {}
			for _, package in ipairs(opts.ensure_installed) do
				if package ~= "chktex" then
					table.insert(filtered, package)
				end
			end
			opts.ensure_installed = filtered

			-- Add all our packages
			vim.list_extend(opts.ensure_installed, {
				-- Python Stack
				"basedpyright",
				"ruff",
				"mypy",
				"debugpy",

				-- LaTeX Stack
				"texlab",
				"latexindent",
				"ltex-ls",
				"bibtex-tidy",

				-- Web Development (Django, HTML, CSS)
				"html-lsp",
				"css-lsp",
				"tailwindcss-language-server",
				"emmet-ls",
				"jinja-lsp",
				"djlint",
				"prettier",
				"prettierd",
				"eslint_d",

				-- JavaScript/TypeScript
				"typescript-language-server",
				"js-debug-adapter",

				-- JSON & YAML
				"json-lsp",
				"yaml-language-server",
				"yamllint",
				"yamlfmt",
				"yamlfix",

				-- TOML
				"taplo",

				-- Docker
				"dockerfile-language-server",
				"docker-compose-language-service",
				"hadolint",

				-- Markdown
				"marksman",
				"markdownlint-cli2",
				"markdown-toc",
				"vale",

				-- Bash/Shell
				"bash-language-server",
				"shellcheck",
				"shfmt",

				-- Lua
				"lua-language-server",
				"stylua",
				"selene",
				"luacheck",

				-- SQL
				"sqls",
				"sql-formatter",
				"sqlfluff",

				-- XML
				"lemminx",
				"xmlformatter",
			})

			return opts
		end,
	},
}
