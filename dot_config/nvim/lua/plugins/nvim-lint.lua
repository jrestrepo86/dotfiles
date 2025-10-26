-- dot_config/nvim/lua/plugins/nvim-lint.lua
-- nvim-lint - Linting configuration
-- Python configured to NOT report unused imports (F401)

return {
	"mfussenegger/nvim-lint",
	opts = {
		linters_by_ft = {
			-- Python: ruff with F401 (unused imports) ignored
			python = { "ruff", "mypy" },

			-- LaTeX
			tex = { "chktex" },

			-- Web
			html = { "djlint" },
			htmldjango = { "djlint" },
			css = {},
			javascript = { "eslint_d" },
			typescript = { "eslint_d" },
			javascriptreact = { "eslint_d" },
			typescriptreact = { "eslint_d" },

			-- Data formats
			json = {},
			yaml = { "yamllint" },

			-- Markdown
			markdown = { "markdownlint-cli2", "vale" },

			-- Bash
			sh = { "shellcheck" },
			bash = { "shellcheck" },

			-- Docker
			dockerfile = { "hadolint" },

			-- Lua
			lua = { "selene", "luacheck" },

			-- SQL
			sql = { "sqlfluff" },
		},

		-- Linter-specific configuration
		linters = {
			-- Python: Ruff - IGNORE F401 (unused imports)
			ruff = {
				cmd = "ruff",
				args = {
					"check",
					"--force-exclude",
					"--quiet",
					"--stdin-filename",
					function()
						return vim.api.nvim_buf_get_name(0)
					end,
					"--no-fix",
					"--output-format",
					"json",
					"--ignore",
					"F401", -- IGNORE unused imports
					"--ignore",
					"F403", -- IGNORE star imports (optional)
					"-",
				},
				stdin = true,
				stream = "stdout",
				ignore_exitcode = true,
				parser = function(output, bufnr)
					if output == "" then
						return {}
					end

					local ok, decoded = pcall(vim.json.decode, output)
					if not ok then
						return {}
					end

					local diagnostics = {}
					for _, item in ipairs(decoded) do
						table.insert(diagnostics, {
							lnum = item.location.row - 1,
							col = item.location.column - 1,
							end_lnum = item.end_location.row - 1,
							end_col = item.end_location.column - 1,
							severity = vim.diagnostic.severity.WARN,
							message = item.message,
							source = "ruff",
							code = item.code,
						})
					end
					return diagnostics
				end,
			},

			-- Python: mypy type checking
			mypy = {
				args = {
					"--show-column-numbers",
					"--show-error-end",
					"--hide-error-codes",
					"--hide-error-context",
					"--no-color-output",
					"--no-error-summary",
					"--no-pretty",
					"--ignore-missing-imports", -- Ignore missing type stubs
					"--follow-imports=silent",
				},
			},

			-- LaTeX: chktex
			chktex = {
				args = {
					"-q", -- Quiet
					"-v0", -- Verbosity 0
					"-I0", -- Don't show input line
					"-f%l:%c:%d:%k:%m\n", -- Custom format
				},
			},

			-- Bash: shellcheck
			shellcheck = {
				args = {
					"--format=json",
					"--shell=bash",
					"--severity=style",
					"-",
				},
			},

			-- Docker: hadolint
			hadolint = {
				args = {
					"--format=json",
					"--no-fail",
					"-",
				},
			},

			-- Django templates
			djlint = {
				cmd = "djlint",
				args = {
					"--lint",
					"--quiet",
					"--format-css",
					"--format-js",
					"-",
				},
			},

			-- Markdown: markdownlint
			["markdownlint-cli2"] = {
				args = {
					"--config",
					vim.fn.expand("~/.markdownlint.yaml"),
				},
			},

			-- YAML: yamllint
			yamllint = {
				args = {
					"--format",
					"parsable",
					"-",
				},
			},

			-- SQL: sqlfluff
			sqlfluff = {
				args = {
					"lint",
					"--format",
					"json",
					"--dialect",
					"postgres", -- Change to mysql, etc. as needed
					"--stdin-filename",
					"$FILENAME",
					"-",
				},
			},

			-- Lua: selene (only run if selene.toml exists)
			selene = {
				condition = function(ctx)
					local root = LazyVim.root.get({ normalize = true })
					if root ~= vim.uv.cwd() then
						return false
					end
					return vim.fs.find({ "selene.toml" }, { path = root, upward = true })[1]
				end,
			},

			-- Lua: luacheck (only run if .luacheckrc exists)
			luacheck = {
				condition = function(ctx)
					local root = LazyVim.root.get({ normalize = true })
					if root ~= vim.uv.cwd() then
						return false
					end
					return vim.fs.find({ ".luacheckrc" }, { path = root, upward = true })[1]
				end,
			},
		},
	},
}
