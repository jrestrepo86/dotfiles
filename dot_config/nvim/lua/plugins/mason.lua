-- ═══════════════════════════════════════════════════════════════════════════════
-- MASON CONFIGURATION - Complete package list for all languages
-- ═══════════════════════════════════════════════════════════════════════════════
-- This ensures all LSP servers, formatters, and linters are installed
-- ═══════════════════════════════════════════════════════════════════════════════

return {
	{
		"mason-org/mason.nvim",
		opts = function(_, opts)
			-- Initialize ensure_installed if it doesn't exist
			opts.ensure_installed = opts.ensure_installed or {}

			-- Remove chktex if LazyVim added it (it's problematic)
			local filtered = {}
			for _, package in ipairs(opts.ensure_installed) do
				if package ~= "chktex" then
					table.insert(filtered, package)
				end
			end
			opts.ensure_installed = filtered

			-- ═══════════════════════════════════════════════════════════════════════════
			-- LANGUAGE SERVERS (LSP)
			-- ═══════════════════════════════════════════════════════════════════════════

			-- Python
			vim.list_extend(opts.ensure_installed, {
				"basedpyright", -- Type checking
				"ruff", -- Fast linting
				"mypy", -- Type checking (additional)
				"debugpy", -- DAP for Python
				"pyrefly", -- Fast completions
			})

			-- LaTeX
			vim.list_extend(opts.ensure_installed, {
				"texlab", -- LaTeX LSP
				"ltex-ls", -- Grammar checking (EN/ES)
			})

			-- YAML
			vim.list_extend(opts.ensure_installed, {
				"yaml-language-server", -- YAML LSP
			})

			-- JSON
			vim.list_extend(opts.ensure_installed, {
				"json-lsp", -- JSON LSP
			})

			-- Web Development (HTML, CSS, Django)
			vim.list_extend(opts.ensure_installed, {
				"html-lsp", -- HTML LSP
				"css-lsp", -- CSS LSP
				"tailwindcss-language-server", -- Tailwind CSS
				"emmet-ls", -- Emmet abbreviations
			})

			-- JavaScript/TypeScript
			vim.list_extend(opts.ensure_installed, {
				"typescript-language-server", -- TS/JS LSP
				"js-debug-adapter", -- DAP for JS/TS
			})

			-- Docker
			vim.list_extend(opts.ensure_installed, {
				"dockerfile-language-server", -- Dockerfile LSP
				"docker-compose-language-service", -- docker-compose LSP
			})

			-- Markdown
			vim.list_extend(opts.ensure_installed, {
				"marksman", -- Markdown LSP
			})

			-- Bash
			vim.list_extend(opts.ensure_installed, {
				"bash-language-server", -- Bash LSP
			})

			-- Lua
			vim.list_extend(opts.ensure_installed, {
				"lua-language-server", -- Lua LSP (for Neovim config)
			})

			-- SQL
			vim.list_extend(opts.ensure_installed, {
				"sqls", -- SQL LSP
			})

			-- TOML
			vim.list_extend(opts.ensure_installed, {
				"taplo", -- TOML LSP
			})

			-- XML
			vim.list_extend(opts.ensure_installed, {
				"lemminx", -- XML LSP
			})
			-- MATLAB
			vim.list_extend(opts.ensure_installed, {
				"matlab-language-server", -- MATLAB LSP
			})
			-- ═══════════════════════════════════════════════════════════════════════════
			-- FORMATTERS
			-- ═══════════════════════════════════════════════════════════════════════════

			-- Python
			vim.list_extend(opts.ensure_installed, {
				"ruff", -- Python formatter (used by conform)
				"isort", -- Python import sorting
			})

			-- LaTeX
			vim.list_extend(opts.ensure_installed, {
				"latexindent", -- LaTeX formatter
				"bibtex-tidy", -- BibTeX formatter
			})

			-- Web
			vim.list_extend(opts.ensure_installed, {
				"prettier", -- Multi-language formatter (HTML, CSS, JS, JSON, MD)
				"prettierd", -- Faster prettier (optional)
				"djlint", -- Django template formatter
			})

			-- YAML
			vim.list_extend(opts.ensure_installed, {
				"yamlfmt", -- YAML formatter
			})

			-- Bash
			vim.list_extend(opts.ensure_installed, {
				"shfmt", -- Shell script formatter
			})

			-- Lua
			vim.list_extend(opts.ensure_installed, {
				"stylua", -- Lua formatter
			})

			-- SQL
			vim.list_extend(opts.ensure_installed, {
				"sql-formatter", -- SQL formatter
			})

			-- XML
			vim.list_extend(opts.ensure_installed, {
				"xmlformatter", -- XML formatter
			})

			-- ═══════════════════════════════════════════════════════════════════════════
			-- LINTERS
			-- ═══════════════════════════════════════════════════════════════════════════

			-- Python (handled by ruff-lsp mostly)
			-- Ruff is already included above

			-- YAML
			vim.list_extend(opts.ensure_installed, {
				"yamllint", -- YAML linter
			})

			-- Markdown
			vim.list_extend(opts.ensure_installed, {
				"markdownlint-cli2", -- Markdown linter
				"vale", -- Prose linter
			})

			-- Bash
			vim.list_extend(opts.ensure_installed, {
				"shellcheck", -- Shell script linter
			})

			-- Docker
			vim.list_extend(opts.ensure_installed, {
				"hadolint", -- Dockerfile linter
			})

			-- JavaScript/TypeScript
			vim.list_extend(opts.ensure_installed, {
				"eslint_d", -- Fast ESLint
			})

			-- Lua
			vim.list_extend(opts.ensure_installed, {
				"selene", -- Lua linter
				"luacheck", -- Lua linter (alternative)
			})

			-- SQL
			vim.list_extend(opts.ensure_installed, {
				"sqlfluff", -- SQL linter
			})

			-- ═══════════════════════════════════════════════════════════════════════════
			-- MASON UI SETTINGS
			-- ═══════════════════════════════════════════════════════════════════════════
			opts.ui = opts.ui or {}
			opts.ui = vim.tbl_deep_extend("force", opts.ui, {
				border = "rounded",
				icons = {
					package_installed = "✓",
					package_pending = "➜",
					package_uninstalled = "✗",
				},
			})

			return opts
		end,
	},
}
