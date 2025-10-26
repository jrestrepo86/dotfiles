-- Simplified Treesitter configuration for LazyVim
-- Just adds parsers and basic config - no complex setup

return {
	{
		"nvim-treesitter/nvim-treesitter",
		opts = function(_, opts)
			-- Add all required parsers
			vim.list_extend(opts.ensure_installed, {
				-- Core
				"python",
				"lua",
				"vim",
				"vimdoc",

				-- LaTeX
				"latex",
				"bibtex",

				-- Web (Django)
				"html",
				"css",
				"scss",
				"javascript",
				"typescript",
				"tsx",

				-- Data formats
				"json",
				"yaml",
				"jsonc",
				"toml",
				"xml",

				-- Markup
				"markdown",
				"markdown_inline",
				"rst",

				-- Shell
				"bash",

				-- DevOps
				"dockerfile",

				-- Git
				"gitcommit",
				"gitignore",
				"diff",

				-- Other
				"sql",
				"regex",
				"comment",
			})

			-- Better highlighting for these
			opts.highlight = opts.highlight or {}
			opts.highlight.enable = true
			opts.highlight.additional_vim_regex_highlighting = { "latex", "markdown", "python" }

			-- Let LSP handle Python and YAML indentation
			opts.indent = opts.indent or {}
			opts.indent.enable = true
			opts.indent.disable = { "python", "yaml" }

			return opts
		end,
	},

	-- Treesitter context (show function/class at top)
	{
		"nvim-treesitter/nvim-treesitter-context",
		event = "VeryLazy",
		opts = {
			enable = true,
			max_lines = 3,
			min_window_height = 20,
		},
		keys = {
			{
				"<leader>ut",
				function()
					require("treesitter-context").toggle()
				end,
				desc = "Toggle Treesitter Context",
			},
		},
	},

	-- Rainbow delimiters
	{
		"HiPhish/rainbow-delimiters.nvim",
		event = "BufReadPost",
		config = function()
			local rainbow_delimiters = require("rainbow-delimiters")

			vim.g.rainbow_delimiters = {
				strategy = {
					[""] = rainbow_delimiters.strategy["global"],
					vim = rainbow_delimiters.strategy["local"],
				},
				query = {
					[""] = "rainbow-delimiters",
					lua = "rainbow-blocks",
					latex = "rainbow-blocks",
				},
				highlight = {
					"RainbowDelimiterRed",
					"RainbowDelimiterYellow",
					"RainbowDelimiterBlue",
					"RainbowDelimiterOrange",
					"RainbowDelimiterGreen",
					"RainbowDelimiterViolet",
					"RainbowDelimiterCyan",
				},
			}
		end,
	},
}

-- I believe the issue is with gitlab.com.
--
-- I replaced the tree-sitter-jsonc repository URL with a GitHub fork, and it works.
-- ~/.local/share/nvim/lazy/nvim-treesitter/lua/nvim-treesitter/parsers.lua line 1149  url = 'https://gitlab.com/WhyNotHugo/tree-sitter-jsonc',
-- by  url = 'https://github.com/sunilunnithan/tree-sitter-jsonc',
