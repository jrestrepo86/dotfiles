-- return {
-- 	{
-- 		"mason-org/mason.nvim",
-- 		opts = {
-- 			ensure_installed = {
-- 				"prettier",
-- 				"prettierd",
-- 				"eslint_d",
-- 				-- python
-- 				-- "basedpyright", -- Better than pyright for modern Python
-- 				-- "mypy", -- Type checking
-- 				-- "pyright",
-- 				-- "isort",
-- 				-- "ruff",
-- 				-- "black",
-- 				-- "pylint",
--
-- 				-- Python (enhanced)
-- 				"basedpyright", -- Better than pyright
-- 				"ruff", -- Fast linter + formatter
-- 				"mypy", -- Type checking
-- 				"debugpy", -- Debugging
-- 				"black", -- Keep for compatibility
-- 				"django-template-lsp",
-- 				"djlint",
--
-- 				-- toml
-- 				"taplo",
-- 				"pyproject-fmt",
--
-- 				-- lua
-- 				"stylua",
-- 				"selene",
-- 				"luacheck",
--
-- 				-- LaTeX (enhanced)
-- 				"texlab", -- LSP
-- 				"latexindent", -- Formatter
-- 				"ltex-ls", -- Grammar/spelling
-- 				"chktex", -- Linter
-- 				"bibtex-tidy", -- BibTeX formatter
--
-- 				-- json
-- 				"json-lsp",
-- 				-- yaml
-- 				"yamllint",
-- 				"yaml-language-server",
-- 				"yamlfmt",
-- 				"yamlfix",
-- 				-- markdown
-- 				"markdownlint-cli2",
-- 				"markdown-toc",
-- 				"vale",
-- 				-- shell
-- 				"shellcheck",
-- 				"shfmt",
-- 				"bash-language-server",
-- 				-- dockerfile
-- 				"dockerfile-language-server",
-- 				"docker-compose-language-service",
-- 				"hadolint",
-- 				-- typescript
-- 				"js-debug-adapter",
-- 				"typescript-language-server",
-- 				-- html
-- 				"html-lsp",
-- 				"jinja-lsp",
-- 				-- matlab
-- 				"matlab-language-server",
-- 				-- css
-- 				"tailwindcss-language-server",
-- 				"css-lsp",
-- 				-- sql
-- 				"sqls",
-- 				"sql-formatter",
-- 				"sqlfluff",
-- 				-- xml
-- 				"xmlformatter",
-- 			},
-- 		},
-- 	},
-- }

-- Complete Mason configuration for all languages
-- Python, LaTeX, Bash, Markdown, Docker, YAML, TOML, Django, HTML, CSS, JSON

return {
	{
		"mason-org/mason.nvim",
		opts = {
			ensure_installed = {
				-- Python Stack
				"basedpyright", -- Modern Python LSP (better than pyright)
				"ruff", -- Fast linter + formatter (replaces black, isort, flake8)
				"mypy", -- Type checking
				"debugpy", -- Python debugger
				"pylint", -- Additional linting (optional, can be heavy)

				-- LaTeX Stack
				"texlab", -- LaTeX LSP
				"latexindent", -- LaTeX formatter
				"ltex-ls", -- Grammar & spelling checker (EN + ES)
				"chktex", -- LaTeX linter
				"bibtex-tidy", -- BibTeX formatter

				-- Web Development (Django, HTML, CSS)
				"html-lsp", -- HTML language server
				"css-lsp", -- CSS language server
				"tailwindcss-language-server", -- Tailwind CSS
				"emmet-ls", -- Emmet abbreviations
				"django-template-lsp", -- Django templates
				"jinja-lsp", -- Jinja templates
				"djlint", -- Django/Jinja linter + formatter
				"prettier", -- Universal web formatter
				"prettierd", -- Faster prettier daemon
				"eslint_d", -- Fast ESLint

				-- JavaScript/TypeScript (for web)
				"typescript-language-server", -- TS/JS LSP
				"js-debug-adapter", -- JS debugger

				-- JSON & YAML
				"json-lsp", -- JSON language server
				"yaml-language-server", -- YAML LSP
				"yamllint", -- YAML linter
				"yamlfmt", -- YAML formatter
				"yamlfix", -- YAML auto-fixer

				-- TOML
				"taplo", -- TOML LSP + formatter
				"pyproject-fmt", -- Format pyproject.toml

				-- Docker
				"dockerfile-language-server", -- Dockerfile LSP
				"docker-compose-language-service", -- Docker Compose LSP
				"hadolint", -- Dockerfile linter

				-- Markdown
				"marksman", -- Markdown LSP
				"markdownlint-cli2", -- Markdown linter
				"markdown-toc", -- Table of contents generator
				"vale", -- Prose linter (style guide)

				-- Bash/Shell
				"bash-language-server", -- Bash LSP
				"shellcheck", -- Shell script linter
				"shfmt", -- Shell script formatter

				-- Lua (for Neovim config)
				"lua-language-server", -- Lua LSP
				"stylua", -- Lua formatter
				"selene", -- Lua linter
				"luacheck", -- Additional Lua linter

				-- SQL (useful for Django)
				"sqls", -- SQL LSP
				"sql-formatter", -- SQL formatter
				"sqlfluff", -- SQL linter

				-- XML (sometimes needed)
				"lemminx", -- XML LSP
				"xmlformatter", -- XML formatter
			},
		},
	},
}
