-- return {
-- 	"lervag/vimtex",
-- 	lazy = false, -- lazy-loading will disable inverse search
-- 	config = function()
-- 		vim.g.vimtex_mappings_disable = { ["n"] = { "K" } } -- disable `K` as it conflicts with LSP hover
-- 		vim.g.vimtex_quickfix_method = vim.fn.executable("pplatex") == 1 and "pplatex" or "latexlog"
--
-- 		vim.g.tex_flavor = "latex"
-- 		vim.g.vimtex_context_pdf_viewer = "qpdfview"
-- 		vim.g.vimtex_view_method = "zathura"
-- 		vim.g.vimtex_complete_recursive_bib = 1
-- 		-- vim.opt.conceallevel = 0
-- 		vim.g.vimtex_toc_config = {
-- 			["name"] = "TOC",
-- 			["layers"] = "content",
-- 			["resize"] = 1,
-- 			["split_width"] = 20,
-- 			["todo_sorted"] = 0,
-- 			["show_help"] = 1,
-- 			["show_numbers"] = 1,
-- 			["mode"] = 2,
-- 			["split_pos"] = "vert rightbelow",
-- 		}
-- 	end,
-- 	keys = {
-- 		{ "<localLeader>l", "", desc = "+vimtex", ft = "tex" },
-- 	},
-- }
--
-- dot_config/nvim/lua/plugins/vimtex.lua
return {
	"lervag/vimtex",
	lazy = false,
	config = function()
		vim.g.vimtex_mappings_disable = { ["n"] = { "K" } }
		vim.g.vimtex_quickfix_method = vim.fn.executable("pplatex") == 1 and "pplatex" or "latexlog"

		-- Viewer configuration
		vim.g.tex_flavor = "latex"
		vim.g.vimtex_view_method = "zathura"
		vim.g.vimtex_view_general_viewer = "zathura"

		-- Compiler settings
		vim.g.vimtex_compiler_method = "latexmk"
		vim.g.vimtex_compiler_latexmk = {
			build_dir = "build",
			callback = 1,
			continuous = 1,
			executable = "latexmk",
			options = {
				"-pdf",
				"-verbose",
				"-file-line-error",
				"-synctex=1",
				"-interaction=nonstopmode",
			},
		}

		-- Better completion
		vim.g.vimtex_complete_enabled = 1
		vim.g.vimtex_complete_recursive_bib = 1
		vim.g.vimtex_complete_close_braces = 1

		-- Syntax and concealment
		vim.g.vimtex_syntax_enabled = 1
		vim.g.vimtex_syntax_conceal_disable = 0

		-- TOC configuration
		vim.g.vimtex_toc_config = {
			name = "TOC",
			layers = { "content", "todo", "include" },
			resize = 1,
			split_width = 30,
			todo_sorted = 0,
			show_help = 1,
			show_numbers = 1,
			mode = 2,
			split_pos = "vert rightbelow",
		}

		-- Quickfix settings
		vim.g.vimtex_quickfix_mode = 0 -- Don't auto-open quickfix
		vim.g.vimtex_quickfix_autoclose_after_keystrokes = 1

		-- Folding
		vim.g.vimtex_fold_enabled = 1
		vim.g.vimtex_fold_manual = 0
	end,

	keys = {
		{ "<localLeader>l", "", desc = "+vimtex", ft = "tex" },
	},
}
