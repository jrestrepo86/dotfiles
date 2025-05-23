return {
	{
		"vague2k/huez.nvim",
		dependencies = { "nvim-telescope/telescope.nvim" },
		-- if you want registry related features, uncomment this
		-- import = "huez-manager.import"
		branch = "stable",
		event = "UIEnter",
		config = function()
			require("huez").setup({})
		end,
	},
	{ "Skardyy/makurai-nvim", lazy = false },
	{
		"rjshkhr/shadow.nvim",
		lazy = false,
	},
	{
		"webhooked/kanso.nvim",
		lazy = false,
		priority = 1000,
	},
	{ "EdenEast/nightfox.nvim", lazy = false },
	{ "mistweaverco/retro-theme.nvim", lazy = false },
	{ "nyoom-engineering/oxocarbon.nvim", lazy = false },
	{ "joshdick/onedark.vim", lazy = false },
	{
		"metalelf0/black-metal-theme-neovim",
		lazy = false,
		priority = 1000,
		config = function()
			require("black-metal").setup({
				-- optional configuration here
			})
			require("black-metal").load()
		end,
	},
	{
		"catppuccin/nvim",
		lazy = false,
		name = "catppuccin",
		opts = {
			integrations = {
				aerial = true,
				alpha = true,
				cmp = true,
				dashboard = true,
				flash = true,
				gitsigns = true,
				headlines = true,
				illuminate = true,
				indent_blankline = { enabled = true },
				leap = true,
				lsp_trouble = true,
				mason = true,
				markdown = true,
				mini = true,
				native_lsp = {
					enabled = true,
					underlines = {
						errors = { "undercurl" },
						hints = { "undercurl" },
						warnings = { "undercurl" },
						information = { "undercurl" },
					},
				},
				navic = { enabled = true, custom_bg = "lualine" },
				neotest = true,
				neotree = true,
				noice = true,
				notify = true,
				semantic_tokens = true,
				telescope = true,
				treesitter = true,
				treesitter_context = true,
				which_key = true,
			},
		},
	},
}
