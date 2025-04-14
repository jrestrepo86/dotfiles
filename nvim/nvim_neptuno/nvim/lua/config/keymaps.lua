local Util = require("lazyvim.util")

local map = function(mode, lhs, rhs, opts)
  local options = { noremap = true, silent = true }
  if opts then
    options = vim.tbl_extend("force", options, opts)
  end
  vim.keymap.set(mode, lhs, rhs, options)
end

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
map({ "i", "n" }, "<esc>", "<cmd>noh<cr><esc>", { desc = "Clear hlsearch and ESC" })

-- save like your are used to
map({ "i", "v", "n", "s" }, "<C-s>", "<cmd>w<cr><esc>", { desc = "Save file" })

-- Select all text
map("n", "<Localleader>e", "gg<S-V>G", { desc = "Select all Text", silent = true, noremap = true })

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
-- map("n", "Localleader<bar>", ":vsp<cr>", { desc = "Same file vertical split" })

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
  require("Comment.api").toggle.linewise.current()  -- Comment the signature line
  vim.api.nvim_win_set_cursor(0, { lineNum + 1, 0 }) -- Move cursor to new date line
  require("Comment.api").toggle.linewise.current()  -- Comment the date line
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
