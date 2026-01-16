return {
	"folke/noice.nvim",
	opts = {
		lsp = {
			signature = {
				auto_open = {
					enabled = false, -- Disable automatic popup
				},
			},
			-- If you also want to disable automatic hover popups (if enabled)
			hover = {
				enabled = true, -- Keep the feature, but trigger manually
				silent = true, -- Don't show a message when no hover is available
			},
		},
	},
}
