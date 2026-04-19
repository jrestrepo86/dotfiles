return {
	{
		"milanglacier/minuet-ai.nvim",
		dependencies = { "nvim-lua/plenary.nvim" },
		event = "InsertEnter",
		config = function()
			require("minuet").setup({
				virtualtext = {
					auto_trigger_ft = {}, -- manual only, saves quota
					keymap = {
						accept_line = "<C-l>",
						prev = "<M-[>",
						dismiss = "<C-]>",
					},
				},
				provider = "gemini",
				provider_options = {
					gemini = {
						model = "gemini-2.5-flash-lite",
						api_key = "GEMINI_API_KEY",
						optional = {
							generationConfig = {
								maxOutputTokens = 256,
								temperature = 0,
							},
						},
					},
				},
			})

			-- Manual trigger: C-. in insert mode
			vim.keymap.set("i", "<C-.>", function()
				require("minuet.virtualtext").action.next()
			end, { desc = "minuet: trigger suggestion" })

			-- Tab: cycle suggestion if visible, otherwise normal tab
			vim.keymap.set("i", "<Tab>", function()
				if require("minuet.virtualtext").action.is_visible() then
					require("minuet.virtualtext").action.next()
				else
					return "\t"
				end
			end, { expr = true, desc = "minuet: next or tab" })

			-- Enter: accept suggestion if visible, otherwise normal newline
			vim.keymap.set("i", "<CR>", function()
				if require("minuet.virtualtext").action.is_visible() then
					require("minuet.virtualtext").action.accept()
				else
					return "\n"
				end
			end, { expr = true, desc = "minuet: accept or newline" })
		end,
	},
}
