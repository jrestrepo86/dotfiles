return {
	-- 1) Avante (keeps LM Studio as your provider)
	{
		"yetone/avante.nvim",
		event = "VeryLazy",
		version = false,
		dependencies = {
			"nvim-lua/plenary.nvim",
			"MunifTanjim/nui.nvim",

			-- -- MCP hub: adds MCP tools/resources to Avante
			-- "ravitemer/mcphub.nvim",

			-- optional QoL deps (install only what you use)
			{ "hrsh7th/nvim-cmp", optional = true },
			{ "nvim-telescope/telescope.nvim", optional = true },
			{ "ibhagwan/fzf-lua", optional = true },
			{ "stevearc/dressing.nvim", optional = true },
			{ "nvim-tree/nvim-web-devicons", optional = true },
		},
		opts = function(_, opts)
			opts = opts or {}
			opts.debug = true
			-- Per-project prompt rules (optional file at repo root)
			opts.instructions_file = "avante.md"

			-- Use LM Studio as the chat provider (OpenAI-compatible)
			opts.provider = "lmstudio"
			opts.providers = vim.tbl_deep_extend("force", (opts.providers or {}), {
				lmstudio = {
					__inherited_from = "openai",
					endpoint = "http://localhost:1234/v1", -- LM Studio: Settings → Local Server
					model = "deepseek/deepseek-r1-0528-qwen3-8b", -- exact id from LM Studio UI
					api_key_name = "LM_API_KEY", -- dummy env var Avante expects
					timeout = 30000,
					extra_request_body = {
						temperature = 0.2,
						max_tokens = 5000,
					},
				},
			})

			-- === MCP integration (via mcphub.nvim) ===
			-- 1) Add MCP tools to Avante
			-- local ok_ext, ext = pcall(require, "mcphub.extensions.avante")
			-- if ok_ext and ext.mcp_tool then
			-- 	opts.custom_tools = function()
			-- 		return { ext.mcp_tool() } -- exposes `use_mcp_tool` & `access_mcp_resource`
			-- 	end
			-- end
			--
			-- -- 2) Optionally show active MCP servers in the system prompt
			-- local ok_hub, mcphub = pcall(require, "mcphub")
			-- if ok_hub then
			-- 	opts.system_prompt = function()
			-- 		local hub = mcphub.get_hub_instance()
			-- 		return hub and hub:get_active_servers_prompt() or ""
			-- 	end
			-- end
			--
			-- -- 3) Avoid overlapping built-ins (let MCP provide file/terminal tools)
			-- opts.disabled_tools = {
			-- 	"list_files",
			-- 	"search_files",
			-- 	"read_file",
			-- 	"create_file",
			-- 	"rename_file",
			-- 	"delete_file",
			-- 	"create_dir",
			-- 	"rename_dir",
			-- 	"delete_dir",
			-- 	"bash",
			-- }

			return opts
		end,
	},
}
