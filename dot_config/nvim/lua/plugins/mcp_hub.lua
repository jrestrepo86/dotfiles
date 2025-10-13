-- -- MCPHub.nvim (Neovim MCP client + hub process)
return {
	"ravitemer/mcphub.nvim",
	dependencies = { "nvim-lua/plenary.nvim" },
	-- recommended: install the hub binary globally
	build = "npm install -g mcp-hub@latest",
	event = "VeryLazy",
	config = function()
		require("mcphub").setup({
			-- creates ~/.config/mcphub/servers.json if missing
			config = vim.fn.expand("~/.config/mcphub/servers.json"),
			port = 37373, -- unified hub port
			shutdown_delay = 5 * 60 * 1000, -- keep hub alive briefly
			use_bundled_binary = false,
			mcp_request_timeout = 60000,
			workspace = {
				enabled = true,
				look_for = { ".mcphub/servers.json", ".vscode/mcp.json", ".cursor/mcp.json" },
				reload_on_dir_changed = true,
				port_range = { min = 40000, max = 41000 },
			},
			auto_approve = false, -- flip to true if you want no confirm UI
			extensions = { avante = { make_slash_commands = true } },
		})
	end,
}
