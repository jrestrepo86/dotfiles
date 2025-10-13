local Util = require("lazyvim.util")

local map = function(mode, lhs, rhs, opts)
	local options = { noremap = true, silent = true }
	if opts then
		options = vim.tbl_extend("force", options, opts)
	end
	vim.keymap.set(mode, lhs, rhs, options)
end

-- Save key strokes (now we do not need to press shift to enter command mode).
map({ "n", "x" }, ";", function()
	-- Use Noice's command line if available, otherwise fallback
	local ok = pcall(require, "noice")
	if ok and require("noice").visible then
		vim.api.nvim_feedkeys(":", "n", true)
	else
		-- Directly trigger command line with proper escaping
		vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(":", true, true, true), "n", true)
	end
end, {
	noremap = true,
	silent = true,
	desc = "Show command line with Noice",
})

-- Turn the word under cursor to upper case
map("i", "<c-u>", "<Esc>viwUea")

-- Turn the current word into title case
map("i", "<c-t>", "<Esc>b~lea")

-- Go to the beginning and end of current line in insert mode quickly
map("i", "<C-A>", "<HOME>", { desc = "Go to the beginning" })
map("i", "<C-E>", "<END>", { desc = "Go to the end" })

-- Don't yank on visual paste
map("v", "p", '"_dP', { silent = true })

-- navigation
map("n", "<C-Up>", "<C-w>k", { desc = "Window up" })
map("n", "<C-Left>", "<C-w>h", { desc = "Window left" })
map("n", "<C-Right>", "<C-w>l", { desc = "Window right" })
map("n", "<C-Down>", "<C-w>j", { desc = "Window down" })
map("i", "<C-Left>", "<C-\\><C-N><C-w>h", { desc = "Window left" })
map("i", "<C-Right>", "<C-\\><C-N><C-w>l", { desc = "Window right" })
map("i", "<C-Down>", "<C-\\><C-N><C-w>j", { desc = "Window down" })
map("i", "<C-Up>", "<C-\\><C-N><C-w>k", { desc = "Window up" })
map("i", "<esc><esc>", "<C-\\><C-N>", { desc = "Escape" })

-- map("n", "<A-Right>", ":tabn<cr>", { desc = "Tab next" })
-- map("n", "<A-Left>", ":tabp<cr>", { desc = "Tab pre" })
map("n", "<A-2>", ":tabn<cr>", { desc = "Tab next" })
map("n", "<A-1>", ":tabp<cr>", { desc = "Tab pre" })
map("n", "<TAB>", ":bnext<cr>", { desc = "Tab next" })
-- map("n", "<A-Down>", ":bprevious<cr>", { desc = "Tab pre" })

-- Cancel search highlighting with ESC
-- map({ "i", "n" }, "<esc>", "<cmd>noh<cr><esc>", { desc = "Clear hlsearch and ESC" })

-- save like your are used to
map({ "i", "v", "n", "s" }, "<C-s>", "<cmd>w<cr><esc>", { desc = "Save file" })

-- Select all text
map("n", "<Localleader>e", "gg<S-V>G", { desc = "Select all Text", silent = true, noremap = true })

-- Duplicate line and comment the first line
map("n", "ycc", "yygccp", { remap = true })

-- U for redo
map("n", "U", "<C-r>", { desc = "Redo" })

-- Deleting without yanking empty line
map("n", "dd", function()
	local is_empty_line = vim.api.nvim_get_current_line():match("^%s*$")
	if is_empty_line then
		return '"_dd'
	else
		return "dd"
	end
end, { noremap = true, expr = true, desc = "Don't Yank Empty Line to Clipboard" })

--comments
map("n", "<Localleader>-", "<ESC><cmd>lua require('Comment.api').toggle.linewise()<CR>", { desc = "Toogle comment" })
map(
	"v",
	"<Localleader>-",
	"<ESC><cmd>lua require('Comment.api').toggle.linewise(vim.fn.visualmode())<CR>",
	{ desc = "Toogle Comment" }
)
map("n", "<Localleader>/", "<ESC><cmd>lua require('Comment.api').toggle.linewise()<CR>", { desc = "Toogle comment" })
map(
	"v",
	"<Localleader>/",
	"<ESC><cmd>lua require('Comment.api').toggle.linewise(vim.fn.visualmode())<CR>",
	{ desc = "Toogle Comment" }
)

-- Split
map("n", "<Localleader>v", ":vsp<cr>", { desc = "Same file vertical split" })
map("n", "<Localleader>s", ":sp<cr>", { desc = "Same file split" })

--stylua: ignore start
map("n", "<leader>dd", function() require("dap").continue() end, { desc = "Continue" })
map("n", "<S-Down>", function() require("dap").step_over() end, { desc = "Step over" })
map("n", "<S-Right>", function() require("dap").step_into() end, { desc = "Step into" })
map("n", "<S-Left>", function() require("dap").step_out() end, { desc = "Step out" })
map("n", "<S-Up>", function() require("dap").toggle_breakpoint() end, { desc = "Toogle break point" })
--stylua: ignore end

-- custom
map("n", "<Localleader>.", function()
	local lineNum, pos = unpack(vim.api.nvim_win_get_cursor(0))
	local line = vim.api.nvim_get_current_line()
	local message = "Juan Felipe Restrepo <juan.restrepo@under.edu.ar>"
	local date = tostring(os.date("%Y-%m-%d"))
	local nline = line:sub(1, pos) .. message .. line:sub(pos + 1)
	vim.api.nvim_set_current_line(nline)
	-- Insert the date on a new line below
	vim.api.nvim_buf_set_lines(0, lineNum, lineNum, false, { date })
	-- Comment both lines
	require("Comment.api").toggle.linewise.current() -- Comment the signature line
	vim.api.nvim_win_set_cursor(0, { lineNum + 1, 0 }) -- Move cursor to new date line
	require("Comment.api").toggle.linewise.current() -- Comment the date line
	vim.api.nvim_win_set_cursor(0, { lineNum, pos })
end, { desc = "Print author info" })

-- Spells
map("n", "<Localleader>zd", ":setlocal nospell<CR> :set mousemodel=extend<CR>", { desc = "Stop spell" })
map("n", "<Localleader>zs", ":setlocal spell spelllang=es<CR> :set mousemodel=popup<CR>", { desc = "Spell Es" })
map("n", "<Localleader>ze", ":setlocal spell spelllang=en<CR> :set mousemodel=popup<CR>", { desc = "Spell En" })
-- Plugin Info
map("n", "<leader>cif", "<cmd>LazyFormatInfo<cr>", { desc = "Formatting" })
map("n", "<leader>cic", "<cmd>ConformInfo<cr>", { desc = "Conform" })
local linters = function()
	local linters_attached = require("lint").linters_by_ft[vim.bo.filetype]
	local buf_linters = {}

	if not linters_attached then
		LazyVim.warn("No linters attached", { title = "Linter" })
		return
	end

	for _, linter in pairs(linters_attached) do
		table.insert(buf_linters, linter)
	end

	local unique_client_names = table.concat(buf_linters, ", ")
	local linters = string.format("%s", unique_client_names)

	LazyVim.notify(linters, { title = "Linter" })
end
map("n", "<leader>ciL", linters, { desc = "Lint" })
