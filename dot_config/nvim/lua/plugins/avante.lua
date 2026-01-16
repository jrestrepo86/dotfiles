return {
	{
		"yetone/avante.nvim",
		event = "VeryLazy",
		lazy = false,
		version = false,
		build = "make",
		opts = {
			provider = "gemini",
			auto_suggestions_provider = "gemini",
			-- NEW: All provider configs must be inside this 'providers' table
			providers = {
				gemini = {
					model = "gemini-2.5-flash-lite", -- Recommended for suggestions to avoid 429 errors
					api_key_name = "GEMINI_API_KEY",
					timeout = 30000,
					-- NEW: Request parameters move here
					extra_request_body = {
						temperature = 0,
						max_tokens = 4096,
					},
				},
			},
			behaviour = {
				auto_suggestions = false, -- Manual trigger only to save your quota
				auto_set_highlight_group = true,
				auto_set_keymaps = true,
				support_paste_from_clipboard = false,
			},
			mappings = {
				suggestion = {
					accept = "<M-.>", -- Alt-. (Meta is mapped to Alt in Neovim)
					next = "<M-]>",
					prev = "<M-[>",
					dismiss = "<C-]>",
				},
			},
		},
		-- CUSTOM TRIGGER: Maps Control-. to manually request a suggestion
		keys = {
			{
				"<C-.>",
				function()
					require("avante.suggestion"):suggest()
				end,
				mode = { "n", "i" },
				desc = "avante: trigger suggestion",
			},
		},
		dependencies = {
			"stevearc/dressing.nvim",
			"nvim-lua/plenary.nvim",
			"MunifTanjim/nui.nvim",
			"nvim-tree/nvim-web-devicons",
		},
	},
}
