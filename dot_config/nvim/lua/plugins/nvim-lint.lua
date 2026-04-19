-- dot_config/nvim/lua/plugins/nvim-lint.lua
-- nvim-lint - Linting configuration
-- Python configured to NOT report unused imports (F401)

return {
	"mfussenegger/nvim-lint",
	opts = {
		linters_by_ft = {
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

			-- Markdown: vale
			vale = {},

			-- SQL: sqlfluff
			sqlfluff = {
				args = {
					"lint",
					"--format",
					"json",
					"--dialect",
					"postgres",
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
