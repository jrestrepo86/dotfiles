-- Language-specific keybindings and settings
-- Extends your existing keymaps.lua

-- Helper function for setting keymaps
local function map(mode, lhs, rhs, opts)
	local options = { noremap = true, silent = true }
	if opts then
		options = vim.tbl_extend("force", options, opts)
	end
	vim.keymap.set(mode, lhs, rhs, options)
end

-- ============================================
-- PYTHON KEYBINDINGS & SETTINGS
-- ============================================
vim.api.nvim_create_autocmd("FileType", {
	pattern = "python",
	callback = function()
		-- Run Python file
		map("n", "<localleader>r", ":w<CR>:!python3 %<CR>", { desc = "Run Python file" })

		-- Run in terminal (split)
		map("n", "<localleader>R", ":w<CR>:split | term python3 %<CR>", { desc = "Run in terminal" })

		-- Interactive Python
		map("n", "<localleader>i", ":w<CR>:term python3 -i %<CR>", { desc = "Interactive Python" })

		-- Testing
		map("n", "<localleader>t", ":!pytest %<CR>", { desc = "Run pytest on file" })
		map("n", "<localleader>T", ":!pytest<CR>", { desc = "Run all tests" })

		-- Django management
		map("n", "<localleader>dm", ":!python manage.py ", { desc = "Django manage.py" })
		map("n", "<localleader>dr", ":!python manage.py runserver<CR>", { desc = "Django runserver" })
		map("n", "<localleader>ds", ":!python manage.py shell<CR>", { desc = "Django shell" })
		map("n", "<localleader>dd", ":!python manage.py makemigrations<CR>", { desc = "Django makemigrations" })
		map("n", "<localleader>dM", ":!python manage.py migrate<CR>", { desc = "Django migrate" })

		-- Type checking
		map("n", "<localleader>m", ":!mypy %<CR>", { desc = "MyPy type check" })

		-- Debugging
		map("n", "<localleader>b", ":lua require'dap'.toggle_breakpoint()<CR>", { desc = "Toggle breakpoint" })
		map("n", "<localleader>B", ":lua require'dap'.continue()<CR>", { desc = "Start/Continue debugging" })

		-- Python-specific settings
		vim.opt_local.expandtab = true
		vim.opt_local.shiftwidth = 4
		vim.opt_local.tabstop = 4
		vim.opt_local.softtabstop = 4
		vim.opt_local.textwidth = 88 -- Black default
		vim.opt_local.colorcolumn = "+1"
	end,
})

-- ============================================
-- LATEX KEYBINDINGS & SETTINGS
-- ============================================
vim.api.nvim_create_autocmd("FileType", {
	pattern = "tex",
	callback = function()
		-- VimTeX already provides <localleader>l prefix
		-- Add quick access commands
		map("n", "<localleader>v", "<cmd>VimtexView<CR>", { desc = "View PDF" })
		map("n", "<localleader>c", "<cmd>VimtexCompile<CR>", { desc = "Compile" })
		map("n", "<localleader>C", "<cmd>VimtexClean<CR>", { desc = "Clean auxiliary files" })
		map("n", "<localleader>e", "<cmd>VimtexErrors<CR>", { desc = "Show errors" })
		map("n", "<localleader>t", "<cmd>VimtexTocToggle<CR>", { desc = "Toggle TOC" })
		map("n", "<localleader>i", "<cmd>VimtexInfo<CR>", { desc = "VimTeX info" })
		map("n", "<localleader>s", "<cmd>VimtexStatus<CR>", { desc = "Compilation status" })

		-- Quick compile + view
		map("n", "<localleader><CR>", "<cmd>VimtexCompile<CR><cmd>VimtexView<CR>", { desc = "Compile & View" })

		-- LaTeX-specific settings
		vim.opt_local.wrap = true
		vim.opt_local.linebreak = true
		vim.opt_local.textwidth = 100
		vim.opt_local.colorcolumn = "+1"
		vim.opt_local.conceallevel = 0 -- Show all LaTeX commands
		vim.opt_local.spell = true
		vim.opt_local.spelllang = "en_us,es" -- English + Spanish
	end,
})

-- ============================================
-- MARKDOWN KEYBINDINGS & SETTINGS
-- ============================================
vim.api.nvim_create_autocmd("FileType", {
	pattern = "markdown",
	callback = function()
		-- Preview
		map("n", "<localleader>p", "<cmd>MarkdownPreview<CR>", { desc = "Markdown preview" })
		map("n", "<localleader>P", "<cmd>MarkdownPreviewStop<CR>", { desc = "Stop preview" })

		-- Table of contents
		map("n", "<localleader>t", ":GenTocGFM<CR>", { desc = "Generate TOC" })

		-- Markdown-specific settings
		vim.opt_local.wrap = true
		vim.opt_local.linebreak = true
		vim.opt_local.textwidth = 80
		vim.opt_local.colorcolumn = "+1"
		vim.opt_local.conceallevel = 2 -- Hide markdown syntax
		vim.opt_local.spell = true
		vim.opt_local.spelllang = "en_us,es"
	end,
})

-- ============================================
-- YAML/DOCKER-COMPOSE SETTINGS
-- ============================================
vim.api.nvim_create_autocmd("FileType", {
	pattern = { "yaml", "yml" },
	callback = function()
		vim.opt_local.expandtab = true
		vim.opt_local.shiftwidth = 2
		vim.opt_local.tabstop = 2
		vim.opt_local.softtabstop = 2

		-- Detect docker-compose files
		local filename = vim.fn.expand("%:t")
		if filename:match("docker%-compose") or filename:match("compose%.ya?ml") then
			vim.bo.filetype = "yaml.docker-compose"
		end
	end,
})

-- ============================================
-- DOCKER SETTINGS
-- ============================================
vim.api.nvim_create_autocmd("FileType", {
	pattern = "dockerfile",
	callback = function()
		map("n", "<localleader>b", ":!docker build -t %:t:r .<CR>", { desc = "Docker build" })
		map("n", "<localleader>r", ":!docker run -it %:t:r<CR>", { desc = "Docker run" })
	end,
})

-- ============================================
-- HTML/CSS/DJANGO TEMPLATES SETTINGS
-- ============================================
vim.api.nvim_create_autocmd("FileType", {
	pattern = { "html", "htmldjango", "css", "scss" },
	callback = function()
		vim.opt_local.expandtab = true
		vim.opt_local.shiftwidth = 2
		vim.opt_local.tabstop = 2
		vim.opt_local.softtabstop = 2

		-- Emmet expansion
		map("i", "<C-e>", "<C-y>,", { desc = "Emmet expand" })

		-- Django template tags (for htmldjango)
		if vim.bo.filetype == "htmldjango" then
			map("n", "<localleader>r", ":!python manage.py runserver<CR>", { desc = "Django runserver" })
		end
	end,
})

-- ============================================
-- JSON/TOML SETTINGS
-- ============================================
vim.api.nvim_create_autocmd("FileType", {
	pattern = { "json", "jsonc", "toml" },
	callback = function()
		vim.opt_local.expandtab = true
		vim.opt_local.shiftwidth = 2
		vim.opt_local.tabstop = 2
		vim.opt_local.softtabstop = 2
	end,
})

-- ============================================
-- BASH/SHELL SETTINGS
-- ============================================
vim.api.nvim_create_autocmd("FileType", {
	pattern = { "sh", "bash" },
	callback = function()
		-- Make script executable
		map("n", "<localleader>x", ":!chmod +x %<CR>", { desc = "Make executable" })

		-- Run script
		map("n", "<localleader>r", ":w<CR>:!bash %<CR>", { desc = "Run bash script" })

		-- ShellCheck
		map("n", "<localleader>l", ":!shellcheck %<CR>", { desc = "ShellCheck lint" })

		vim.opt_local.expandtab = true
		vim.opt_local.shiftwidth = 2
		vim.opt_local.tabstop = 2
	end,
})

-- ============================================
-- SQL SETTINGS
-- ============================================
vim.api.nvim_create_autocmd("FileType", {
	pattern = "sql",
	callback = function()
		vim.opt_local.expandtab = true
		vim.opt_local.shiftwidth = 2
		vim.opt_local.tabstop = 2

		-- Run SQL query (customize for your DB)
		map("n", "<localleader>r", ":!psql -f %<CR>", { desc = "Run SQL file" })
	end,
})

-- ============================================
-- GLOBAL LANGUAGE SWITCHING
-- ============================================
-- Quick spell language switching
map("n", "<localleader>ze", ":setlocal spell spelllang=en_us<CR>", { desc = "English spell" })
map("n", "<localleader>zs", ":setlocal spell spelllang=es<CR>", { desc = "Spanish spell" })
map("n", "<localleader>zb", ":setlocal spell spelllang=en_us,es<CR>", { desc = "Both languages spell" })
map("n", "<localleader>zd", ":setlocal nospell<CR>", { desc = "Disable spell" })

-- Toggle ltex language (for grammar checking)
local function toggle_ltex_language()
	local clients = vim.lsp.get_active_clients({ bufnr = 0 })
	for _, client in ipairs(clients) do
		if client.name == "ltex" then
			local current = client.config.settings.ltex.language
			local new_lang = current == "en-US" and "es" or "en-US"
			client.config.settings.ltex.language = new_lang
			vim.notify("ltex language: " .. new_lang, vim.log.levels.INFO)
			vim.lsp.buf_notify(0, "workspace/didChangeConfiguration", { settings = client.config.settings })
			return
		end
	end
	vim.notify("ltex not active", vim.log.levels.WARN)
end

map("n", "<localleader>zl", toggle_ltex_language, { desc = "Toggle ltex language (EN/ES)" })

-- ============================================
-- FILETYPE DETECTION IMPROVEMENTS
-- ============================================
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
	pattern = { "*.jinja", "*.jinja2", "*.j2" },
	callback = function()
		vim.bo.filetype = "htmldjango"
	end,
})

vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
	pattern = "docker-compose*.yml",
	callback = function()
		vim.bo.filetype = "yaml.docker-compose"
	end,
})

vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
	pattern = "*.py",
	callback = function()
		-- Detect Django files
		local path = vim.fn.expand("%:p")
		if path:match("models%.py$") or path:match("views%.py$") or path:match("urls%.py$") then
			vim.b.is_django = true
		end
	end,
})

return {}
