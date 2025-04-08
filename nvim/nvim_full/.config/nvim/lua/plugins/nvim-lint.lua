return {
	"mfussenegger/nvim-lint",
	opts = {
		linters_by_ft = {
			lua = { "selene", "luacheck" },
			javascript = { "eslint_d" },
			typescript = { "eslint_d" },
			javascriptreact = { "eslint_d" },
			typescriptreact = { "eslint_d" },
			svelte = { "eslint_d" },
			-- python = { "pylint" },
			bash = { "shellcheck" },
			sh = { "shellcheck" },
			dockerfile = { "hadolint" },
			-- https://stackoverflow.com/questions/62369711/how-to-install-hadolint-on-ubuntu
			makrdown = { "markdownlint-cli2", "vale" },
		},
		linters = {
			selene = {
				condition = function(ctx)
					local root = LazyVim.root.get({ normalize = true })
					if root ~= vim.uv.cwd() then
						return false
					end
					return vim.fs.find({ "selene.toml" }, { path = root, upward = true })[1]
				end,
			},
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
