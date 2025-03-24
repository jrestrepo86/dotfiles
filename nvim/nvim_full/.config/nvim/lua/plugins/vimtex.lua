return {
	"lervag/vimtex",
	lazy = false, -- lazy-loading will disable inverse search
	config = function()
		vim.g.vimtex_mappings_disable = { ["n"] = { "K" } } -- disable `K` as it conflicts with LSP hover
		vim.g.vimtex_quickfix_method = vim.fn.executable("pplatex") == 1 and "pplatex" or "latexlog"

		vim.g.tex_flavor = "latex"
		vim.g.vimtex_context_pdf_viewer = "qpdfview"
		vim.g.vimtex_view_method = "zathura"
		vim.g.vimtex_complete_recursive_bib = 1
		-- vim.opt.conceallevel = 0
		vim.g.vimtex_toc_config = {
			["name"] = "TOC",
			["layers"] = "content",
			["resize"] = 1,
			["split_width"] = 20,
			["todo_sorted"] = 0,
			["show_help"] = 1,
			["show_numbers"] = 1,
			["mode"] = 2,
			["split_pos"] = "vert rightbelow",
		}
	end,
	keys = {
		{ "<localLeader>l", "", desc = "+vimtex", ft = "tex" },
	},
}
