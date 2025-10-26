-- Conform.nvim - Formatting configuration
-- CRITICAL: Python formatters configured to NOT remove unused imports

return {
	{
		"stevearc/conform.nvim",
		opts = {
			formatters_by_ft = {
				-- Python: ruff_format only (does NOT remove imports)
				-- ruff_organize_imports is EXCLUDED to preserve unused imports
				python = { "ruff_format" },

				-- LaTeX
				tex = { "latexindent" },
				bib = { "bibtex-tidy" },

				-- Web (Django, HTML, CSS)
				html = { "prettier" },
				htmldjango = { "djlint" }, -- Django templates
				css = { "prettier" },
				scss = { "prettier" },
				javascript = { "prettier" },
				typescript = { "prettier" },
				javascriptreact = { "prettier" },
				typescriptreact = { "prettier" },

				-- Data formats
				json = { "prettier" },
				jsonc = { "prettier" },
				yaml = { "yamlfmt" },
				toml = { "taplo" },
				xml = { "xmlformatter" },

				-- Markdown
				markdown = { "prettier" },

				-- Bash
				sh = { "shfmt" },
				bash = { "shfmt" },

				-- Lua
				lua = { "stylua" },

				-- SQL
				sql = { "sql_formatter" },

				-- Docker
				dockerfile = {},
			},

			-- Formatter-specific options
			formatters = {
				-- Python: Ruff formatter (does NOT touch imports)
				ruff_format = {
					command = "ruff",
					args = {
						"format",
						"--force-exclude",
						"--line-length=88", -- Black-compatible
						"--stdin-filename",
						"$FILENAME",
						"-",
					},
					stdin = true,
				},

				-- LaTeX: latexindent
				latexindent = {
					prepend_args = {
						"-m", -- Modify line breaks
						"-l", -- Use local settings if available
					},
				},

				-- Django templates
				djlint = {
					args = {
						"--reformat",
						"--indent=2",
						"--quiet",
						"-",
					},
				},

				-- Bash
				shfmt = {
					prepend_args = {
						"-i",
						"2", -- Indent with 2 spaces
						"-bn", -- Binary ops like && and | may start a line
						"-ci", -- Indent switch cases
						"-sr", -- Redirect operators will be followed by a space
					},
				},

				-- YAML
				yamlfmt = {
					prepend_args = {
						"-formatter",
						"indentless_arrays=true,retain_line_breaks=true",
					},
				},

				-- SQL
				sql_formatter = {
					prepend_args = {
						"--language",
						"postgresql", -- or "mysql", "mariadb", etc.
						"--indent",
						"2",
					},
				},
			},
		},
	},
}
