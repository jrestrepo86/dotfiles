-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here

local augroup = vim.api.nvim_create_augroup
local cmd = vim.api.nvim_create_autocmd

-- Display a message when the current file is not in utf-8 format.
-- Note that we need to use `unsilent` command here because of this issue:
-- https://github.com/vim/vim/issues/4379
cmd({ "BufRead" }, {
	pattern = "*",
	group = augroup("non_utf8_file", { clear = true }),
	callback = function()
		if vim.bo.fileencoding ~= "utf-8" then
			vim.notify("File not in UTF-8 format!", vim.log.levels.WARN, { title = "nvim-config" })
		end
	end,
})

-- don't auto comment new line
cmd("BufEnter", { command = [[set formatoptions-=cro]] })

-- Removes any trailing whitespace when saving a file
cmd({ "BufWritePre" }, {
	desc = "remove trailing whitespace on save",
	group = augroup("remove trailing whitespace", { clear = true }),
	pattern = { "*" },
	command = [[%s/\s\+$//e]],
})

-- close some filetypes with <q>
cmd("FileType", {
	group = augroup("close_with_q", { clear = true }),
	pattern = {
		"PlenaryTestPopup",
		"help",
		"lspinfo",
		"hover",
		"man",
		"notify",
		"qf",
		"query",
		"spectre_panel",
		"dap-float",
		"startuptime",
		"tsplayground",
		"neotest-output",
		"checkhealth",
		"neotest-summary",
		"neotest-output-panel",
	},
	callback = function(event)
		vim.bo[event.buf].buflisted = false
		vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = event.buf, silent = true })
	end,
})
-- Python options
cmd({ "BufEnter", "BufWinEnter", "FileType", "WinEnter" }, {
	pattern = "*.py",
	callback = function()
		vim.opt.expandtab = true -- convert tabs to spaces
		vim.opt.shiftwidth = 4 -- the number of spaces inserted for each indentation
		vim.opt.tabstop = 4 -- insert 4 spaces for a tab
		vim.opt.softtabstop = 4
		vim.opt.wrap = false
		vim.opt.sidescrolloff = 2 -- Makes sure there are always eight lines of context
		vim.opt.sidescroll = 5
		vim.bo.textwidth = 87
		vim.wo.colorcolumn = "+1"
	end,
})

-- Yaml options
cmd({ "BufEnter", "BufWinEnter", "FileType", "WinEnter" }, {
	pattern = "{*.yml,*.yaml}",
	callback = function()
		vim.opt.tabstop = 2
		vim.opt.shiftwidth = 2
		vim.opt.softtabstop = 2
	end,
})
-- Latex options
cmd({ "BufEnter", "BufWinEnter", "FileType", "WinEnter" }, {
	pattern = "*.tex",
	callback = function()
		vim.bo.textwidth = 114
		vim.wo.colorcolumn = "+1"
		vim.opt.wrap = true
		vim.opt.conceallevel = 0
	end,
})

-- sass compile
cmd("BufWritePost", {
	pattern = "*.scss",
	callback = function()
		vim.cmd([[silent exec "!sass --update --no-source-map %:p:%:r.css"]])
	end,
})

-- Markdown
cmd({ "BufEnter", "BufWinEnter", "FileType", "WinEnter" }, {
	pattern = "*.md",
	callback = function()
		vim.bo.textwidth = 80
		vim.wo.colorcolumn = "+1"
		vim.opt.conceallevel = 2 -- Show `` in specific files
		-- do not close the preview tab when switching to other buffers
		vim.g.mkdp_auto_close = 0
	end,
})

-- Jinja
cmd({ "BufEnter", "BufWinEnter", "WinEnter" }, {
	pattern = { "*.jinja", "*.jinja2", "*.j2" },
	callback = function()
		vim.bo.ft = "htmldjango"
	end,
})

cmd({ "BufRead", "BufNewFile" }, {
	pattern = { "*.txt", "*.md", "*.tex", "*.typ" },
	callback = function()
		vim.opt.spell = true
		vim.opt.spelllang = "en,es"
	end,
	desc = "Enable spell checking for certain file types",
})
