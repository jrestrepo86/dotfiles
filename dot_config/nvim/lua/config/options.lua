-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
-- https://github.com/dpetka2001/dotfiles/blob/main/dot_config/nvim/lua/plugins/lsp.lua

vim.g.mapleader = " "
vim.g.maplocalleader = "."

vim.g.python3_host_prog = "/bin/python3"
vim.g.ruby_host_prog = "/usr/local/bin/neovim-ruby-host"
vim.g.loaded_perl_provider = 0

-- cambiar config a dropbox
-- local old_stdpath = vim.fn.stdpath
-- vim.fn.stdpath = function(value)
--   if value == "config" then
--     return vim.fn.expand("~/Dropbox/scripts/dotfiles/nvim/nvim_apolo/.config/nvim/")
--   end
--   return old_stdpath(value)
-- end

-- lazyvim option
-- Enable LazyVim auto format
vim.g.autoformat = true

-- LazyVim root dir detection
-- Each entry can be:
-- * the name of a detector function like `lsp` or `cwd`
-- * a pattern or array of patterns like `.git` or `lua`.
-- * a function with signature `function(buf) -> string|string[]`
vim.g.root_spec = { "lsp", { ".git", "lua" }, "cwd" }

-- Set to false to disable.
vim.g.lazygit_config = true

-- global options
local options = {

	autowrite = false, -- Enable auto write
	backup = false, -- creates a backup file
	clipboard = "unnamedplus", -- allows neovim to access the system clipboard
	completeopt = { "menu", "menuone", "noselect" }, -- mostly just for cmp
	conceallevel = 2, -- so that `` is visible in markdown files
	cursorline = false, -- highlight the current line
	expandtab = true, -- convert tabs to spaces
	fileencoding = "utf-8", -- the encoding written to a file
	formatoptions = "jcroqlnt", -- tcqj
	grepformat = "%f:%l:%c:%m",
	grepprg = "rg --vimgrep",

	hlsearch = true, -- highlight all matches on previous search pattern
	ignorecase = true, -- ignore case in search patterns
	inccommand = "nosplit", -- preview incremental substitute

	laststatus = 3, -- global statusline
	list = true, -- Show some invisible characters (tabs...
	mouse = "a", -- Enable mouse mode
	number = true, -- Print line number
	pumblend = 10, -- Popup blend
	pumheight = 10, -- Maximum number of entries in a popup
	relativenumber = false, -- set relative numbered lines
	scrolloff = 8, -- Lines of context
	sessionoptions = { "buffers", "curdir", "tabpages", "winsize", "help", "globals", "skiprtp", "folds" },
	shiftround = true, -- Round indent
	shiftwidth = 2, -- Size of an indent
	showmode = false, -- Dont show mode since we have a statusline
	sidescrolloff = 8, -- Columns of context
	signcolumn = "yes", -- Always show the signcolumn, otherwise it would shift the text each time
	smartcase = true, -- Don't ignore case with capitals
	smartindent = true, -- Insert indents automatically
	spelllang = { "en" },
	splitbelow = true, -- Put new windows below current
	splitkeep = "screen",
	splitright = true, -- Put new windows right of current
	swapfile = false, -- creates a swapfile
	tabstop = 2, -- Number of spaces tabs count for

	timeout = true,
	timeoutlen = 500, -- time to wait for a mapped sequence to complete (in milliseconds)
	title = true,
	termguicolors = true, -- True color support

	autochdir = true,
	autoindent = true,
	-- cmdheight = 1, -- more space in the neovim command line for displaying messages
	writebackup = false, -- if a file is being edited by another program (or was written to file while editing with another program), it is not allowed to be edited

	undofile = true,
	undolevels = 10000,
	updatetime = 200, -- Save swap file and trigger CursorHold
	virtualedit = "block", -- Allow cursor to move where there is no text in visual block mode
	wildmode = "longest:full,full", -- Command-line completion mode
	winminwidth = 5, -- Minimum window width
	wrap = false, -- Disable line wrap
	fillchars = {
		foldopen = "",
		foldclose = "",
		-- fold = "⸱",
		fold = " ",
		foldsep = " ",
		diff = "╱",
		eob = " ",
	},
	foldlevel = 99,

	spell = false,
}

vim.opt.shortmess:append({ W = true, I = true, c = true, C = true })
vim.opt.iskeyword:append("-") -- consider string-string as whole word

for k, v in pairs(options) do
	vim.opt[k] = v
end
