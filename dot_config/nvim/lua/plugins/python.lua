-- dot_config/nvim/lua/plugins/python.lua
-- Python-specific plugin overrides: neotest + DAP

return {
	-- neotest: inline test runner with conda/venv support
	{
		"nvim-neotest/neotest",
		dependencies = { "nvim-neotest/neotest-python" },
		opts = {
			adapters = {
				["neotest-python"] = {
					runner = "pytest",
					python = function()
						local venv = os.getenv("CONDA_PREFIX") or os.getenv("VIRTUAL_ENV")
						if venv then
							return venv .. "/bin/python"
						end
						return vim.fn.exepath("python3")
					end,
					pytest_discover_instances = true,
				},
			},
		},
	},

	-- nvim-dap-python: use conda/venv Python for debugger
	{
		"mfussenegger/nvim-dap-python",
		config = function()
			local python = (os.getenv("CONDA_PREFIX") or os.getenv("VIRTUAL_ENV") or "")
				.. "/bin/python"
			if vim.fn.executable(python) == 0 then
				python = vim.fn.exepath("python3")
			end
			require("dap-python").setup(python)
			require("dap-python").test_runner = "pytest"
		end,
	},
}
