-- Additional treesitter configuration via autocmds
-- Place this in: ~/.config/nvim/lua/config/autocmds.lua (append to your existing file)
-- Or create: ~/.config/nvim/lua/plugins/treesitter-extras.lua

-- -- Register htmldjango filetype with html treesitter parser
-- vim.treesitter.language.register("html", "htmldjango")
--
-- -- Fix for Python f-strings - reparse when entering Python files
-- vim.api.nvim_create_autocmd("FileType", {
-- 	pattern = "python",
-- 	callback = function()
-- 		local parser = vim.treesitter.get_parser(0, "python")
-- 		if parser then
-- 			parser:parse()
-- 		end
-- 	end,
-- 	desc = "Reparse Python buffer for f-strings",
-- })
--
-- -- Better folding with treesitter
-- vim.api.nvim_create_autocmd("FileType", {
-- 	pattern = "*",
-- 	callback = function()
-- 		-- Only set if treesitter is available for this filetype
-- 		local has_ts = pcall(vim.treesitter.get_parser, 0)
-- 		if has_ts then
-- 			vim.opt_local.foldmethod = "expr"
-- 			vim.opt_local.foldexpr = "v:lua.vim.treesitter.foldexpr()"
-- 			vim.opt_local.foldenable = false -- Don't fold by default
-- 		end
-- 	end,
-- 	desc = "Setup treesitter folding",
-- })
--

-- -- Utilities
-- local function is_normal_loaded_file(bufnr)
-- 	if not bufnr or bufnr == 0 then
-- 		bufnr = vim.api.nvim_get_current_buf()
-- 	end
-- 	if not vim.api.nvim_buf_is_loaded(bufnr) then
-- 		return false
-- 	end
-- 	-- Skip terminals, nofile, dap, quickfix, etc.
-- 	if vim.bo[bufnr].buftype ~= "" then
-- 		return false
-- 	end
-- 	-- Skip unnamed buffers
-- 	local name = vim.api.nvim_buf_get_name(bufnr)
-- 	if not name or name == "" then
-- 		return false
-- 	end
-- 	return true
-- end
--
-- -- Safe check for parser availability without forcing creation
-- local function has_ts_parser(ft)
-- 	local ok, parsers = pcall(require, "nvim-treesitter.parsers")
-- 	if not ok then
-- 		return false
-- 	end
-- 	return parsers.has_parser(ft)
-- end
--
-- -- Fix for Python f-strings (only on real, loaded Python files)
-- vim.api.nvim_create_autocmd("FileType", {
-- 	pattern = "python",
-- 	callback = function(args)
-- 		local bufnr = args.buf
-- 		if not is_normal_loaded_file(bufnr) then
-- 			return
-- 		end
-- 		-- Use start() instead of get_parser(): safer and idempotent
-- 		pcall(vim.treesitter.start, bufnr, "python")
-- 		-- Optionally request a reparse (protected)
-- 		pcall(function()
-- 			local parser = vim.treesitter.get_parser(bufnr, "python")
-- 			if parser then
-- 				parser:parse()
-- 			end
-- 		end)
-- 	end,
-- 	desc = "Safely (re)initialize Treesitter for Python buffers",
-- })
--
-- -- Better folding with treesitter, but only if parser exists and buffer is normal
-- vim.api.nvim_create_autocmd({ "BufWinEnter", "BufReadPost" }, {
-- 	callback = function(args)
-- 		local bufnr = args.buf
-- 		if not is_normal_loaded_file(bufnr) then
-- 			return
-- 		end
-- 		local ft = vim.bo[bufnr].filetype
-- 		if not has_ts_parser(ft) then
-- 			return
-- 		end
-- 		-- Do NOT force parser creation here; just set options
-- 		vim.opt_local.foldmethod = "expr"
-- 		vim.opt_local.foldexpr = "v:lua.vim.treesitter.foldexpr()"
-- 		vim.opt_local.foldenable = false -- Don't fold by default
-- 	end,
-- 	desc = "Setup Treesitter-based folding safely",
-- })
--
-- return {}
--
--

-- ~/.config/nvim/lua/plugins/treesitter-extras.lua

-- Be defensive across Neovim/nvim-treesitter versions.

-- Register htmldjango -> html, but guard in case API isn't present
pcall(function()
	if vim.treesitter.language and vim.treesitter.language.register then
		vim.treesitter.language.register("html", "htmldjango")
	end
end)

-- ---------- utils ----------
local function is_normal_loaded_file(bufnr)
	bufnr = (bufnr and bufnr ~= 0) and bufnr or vim.api.nvim_get_current_buf()
	if not vim.api.nvim_buf_is_loaded(bufnr) then
		return false
	end
	if vim.bo[bufnr].buftype ~= "" then
		return false
	end
	local name = vim.api.nvim_buf_get_name(bufnr)
	if not name or name == "" then
		return false
	end
	return true
end

-- Version-agnostic "do we have a parser?" check:
-- Try starting treesitter (safe), then try getting the parser in a pcall.
local function has_ts_for_buffer(bufnr, lang)
	-- Start won't throw if grammar is missing (it just no-ops on newer versions)
	pcall(vim.treesitter.start, bufnr, lang)
	local ok, parser = pcall(vim.treesitter.get_parser, bufnr, lang)
	return ok and parser ~= nil
end

-- ---------- python: safer init ----------
vim.api.nvim_create_autocmd("FileType", {
	pattern = "python",
	callback = function(args)
		local bufnr = args.buf
		if not is_normal_loaded_file(bufnr) then
			return
		end
		-- initialize treesitter for python if available
		pcall(vim.treesitter.start, bufnr, "python")
		-- optional: force a parse if parser exists
		local ok, parser = pcall(vim.treesitter.get_parser, bufnr, "python")
		if ok and parser then
			pcall(function()
				parser:parse()
			end)
		end
	end,
	desc = "Safely (re)initialize Treesitter for Python buffers",
})

-- ---------- folding with TS, but only on real files and if a parser is available ----------
vim.api.nvim_create_autocmd({ "BufWinEnter", "BufReadPost" }, {
	callback = function(args)
		local bufnr = args.buf
		if not is_normal_loaded_file(bufnr) then
			return
		end
		local ft = vim.bo[bufnr].filetype
		if not has_ts_for_buffer(bufnr, ft) then
			return
		end
		vim.opt_local.foldmethod = "expr"
		vim.opt_local.foldexpr = "v:lua.vim.treesitter.foldexpr()"
		vim.opt_local.foldenable = false -- don't auto-fold on open
	end,
	desc = "Setup Treesitter-based folding safely",
})

return {}
