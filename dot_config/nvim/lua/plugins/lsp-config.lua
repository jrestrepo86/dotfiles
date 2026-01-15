-- ═══════════════════════════════════════════════════════════════════════════════
-- COMPREHENSIVE LSP CONFIGURATION FOR ALL LANGUAGES
-- ═══════════════════════════════════════════════════════════════════════════════
-- Supports: Python, LaTeX, YAML, JSON, HTML/CSS/Django, JS/TS, Docker,
--           Markdown, Bash, Lua, SQL, XML, TOML
-- FIXED: Inline hints disabled at start, tsserver → ts_ls
-- ═══════════════════════════════════════════════════════════════════════════════

return {
	{
		"neovim/nvim-lspconfig",
		opts = function(_, opts)
			-- Initialize servers table
			opts.servers = opts.servers or {}

			-- Get schemastore once (safe check)
			local has_schemastore, schemastore = pcall(require, "schemastore")

			-- ═══════════════════════════════════════════════════════════════════════════
			-- GLOBAL INLAY HINTS - DISABLED AT START
			-- ═══════════════════════════════════════════════════════════════════════════
			opts.inlay_hints = opts.inlay_hints or {}
			opts.inlay_hints.enabled = false -- ⭐ DISABLED AT START

			-- ═══════════════════════════════════════════════════════════════════════════
			-- PYTHON - Multi-LSP Strategy:
			-- • basedpyright: Type checking, hover, navigation, diagnostics
			-- • ruff: Linting diagnostics (formatting via conform)
			-- ═══════════════════════════════════════════════════════════════════════════

			opts.servers.pyright = false -- ⭐ Disable regular pyright

			-- basedpyright: Type checking + LSP features
			opts.servers.basedpyright = {
				settings = {
					basedpyright = {
						analysis = {
							typeCheckingMode = "basic", -- "off" | "basic" | "strict"
							autoSearchPaths = true,
							useLibraryCodeForTypes = true,
							diagnosticMode = "workspace",
							autoImportCompletions = true,
							-- IMPORTANT: Don't report unused imports/variables
							diagnosticSeverityOverrides = {
								reportUnusedImport = "none",
								reportUnusedVariable = "none",
								reportUnusedClass = "none",
								reportUnusedFunction = "none",
							},
							stubPath = vim.fn.stdpath("data") .. "/lazy/python-type-stubs",
						},
					},
				},
			}

			-- ruff: Linting diagnostics ONLY
			opts.servers.ruff = {
				on_attach = function(client, bufnr)
					-- Disable hover (basedpyright handles this)
					client.server_capabilities.hoverProvider = false
					-- Disable formatting (conform handles this)
					client.server_capabilities.documentFormattingProvider = false
					client.server_capabilities.documentRangeFormattingProvider = false
				end,
				init_options = {
					settings = {
						-- Ignore unused imports in ruff too
						args = {
							"--ignore=F401", -- unused imports
							"--ignore=F403", -- star imports
						},
					},
				},
			}

			-- ═══════════════════════════════════════════════════════════════════════════
			-- LATEX - texlab for LSP, ltex for grammar checking
			-- ═══════════════════════════════════════════════════════════════════════════
			opts.servers.texlab = {
				settings = {
					texlab = {
						build = {
							executable = "latexmk",
							args = {
								"-pdf",
								"-interaction=nonstopmode",
								"-synctex=1",
								"-output-directory=build",
								"%f",
							},
							onSave = true,
							forwardSearchAfter = false,
						},
						forwardSearch = {
							executable = "zathura",
							args = { "--synctex-forward", "%l:1:%f", "%p" },
						},
						chktex = {
							onEdit = false,
							onOpenAndSave = true,
						},
						diagnosticsDelay = 300,
						latexFormatter = "latexindent",
						latexindent = {
							modifyLineBreaks = true,
						},
					},
				},
			}

			-- Grammar checking for English + Spanish
			opts.servers.ltex = {
				settings = {
					ltex = {
						language = "en-US",
						additionalRules = {
							enablePickyRules = true,
							motherTongue = "es",
						},
						["ltex-ls"] = {
							logLevel = "warning",
						},
						enabled = {
							"latex",
							"markdown",
							"restructuredtext",
						},
						dictionary = {
							["en-US"] = {
								"LaTeX",
								"BibTeX",
								"Neovim",
								"Django",
								"Python",
								"NumPy",
								"Matplotlib",
								"PyTorch",
								"sklearn",
								"API",
								"JSON",
								"YAML",
								"PostgreSQL",
							},
							["es"] = {
								"software",
								"hardware",
								"internet",
							},
						},
						disabledRules = {
							["en-US"] = { "MORFOLOGIK_RULE_EN_US" },
							["es"] = {},
						},
					},
				},
				filetypes = { "tex", "latex", "markdown", "rst" },
			}

			-- ═══════════════════════════════════════════════════════════════════════════
			-- YAML - With schema support
			-- ═══════════════════════════════════════════════════════════════════════════
			opts.servers.yamlls = {
				settings = {
					yaml = {
						schemaStore = {
							enable = true,
							url = "https://www.schemastore.org/api/json/catalog.json",
						},
						schemas = has_schemastore and schemastore.yaml.schemas() or {},
						format = {
							enable = true,
							singleQuote = false,
							bracketSpacing = true,
						},
						validate = true,
						hover = true,
						completion = true,
						customTags = {
							"!reference sequence",
							"!And",
							"!If",
							"!Not",
							"!Equals",
							"!Or",
							"!FindInMap sequence",
							"!Base64",
							"!Cidr",
							"!Ref",
							"!Sub",
							"!GetAtt",
							"!GetAZs",
							"!ImportValue",
							"!Select",
							"!Split",
							"!Join sequence",
						},
					},
					redhat = {
						telemetry = {
							enabled = false,
						},
					},
				},
			}

			-- ═══════════════════════════════════════════════════════════════════════════
			-- JSON - With schema support
			-- ═══════════════════════════════════════════════════════════════════════════
			opts.servers.jsonls = {
				settings = {
					json = {
						schemas = has_schemastore and schemastore.json.schemas() or {},
						validate = { enable = true },
						format = {
							enable = true,
						},
					},
				},
			}

			-- ═══════════════════════════════════════════════════════════════════════════
			-- WEB DEVELOPMENT - HTML, CSS, Django Templates
			-- ═══════════════════════════════════════════════════════════════════════════
			opts.servers.html = {
				filetypes = { "html", "htmldjango" },
				settings = {
					html = {
						format = {
							enable = true,
						},
					},
				},
			}

			opts.servers.cssls = {
				settings = {
					css = {
						validate = true,
						lint = {
							unknownAtRules = "ignore",
						},
					},
					scss = {
						validate = true,
					},
					less = {
						validate = true,
					},
				},
			}

			opts.servers.tailwindcss = {
				filetypes = {
					"html",
					"htmldjango",
					"css",
					"scss",
					"javascript",
					"javascriptreact",
					"typescript",
					"typescriptreact",
				},
				settings = {
					tailwindCSS = {
						classAttributes = { "class", "className", "classList", "ngClass" },
						lint = {
							cssConflict = "warning",
							invalidApply = "error",
							invalidConfigPath = "error",
							invalidScreen = "error",
							invalidTailwindDirective = "error",
							invalidVariant = "error",
							recommendedVariantOrder = "warning",
						},
						validate = true,
					},
				},
			}

			opts.servers.emmet_ls = {
				filetypes = {
					"html",
					"htmldjango",
					"css",
					"scss",
					"javascript",
					"javascriptreact",
					"typescript",
					"typescriptreact",
				},
			}

			-- ═══════════════════════════════════════════════════════════════════════════
			-- JAVASCRIPT/TYPESCRIPT - FIXED: ts_ls instead of tsserver
			-- ═══════════════════════════════════════════════════════════════════════════
			opts.servers.ts_ls = {
				settings = {
					typescript = {
						inlayHints = {
							includeInlayParameterNameHints = "all",
							includeInlayParameterNameHintsWhenArgumentMatchesName = false,
							includeInlayFunctionParameterTypeHints = true,
							includeInlayVariableTypeHints = true,
							includeInlayPropertyDeclarationTypeHints = true,
							includeInlayFunctionLikeReturnTypeHints = true,
							includeInlayEnumMemberValueHints = true,
						},
					},
					javascript = {
						inlayHints = {
							includeInlayParameterNameHints = "all",
							includeInlayParameterNameHintsWhenArgumentMatchesName = false,
							includeInlayFunctionParameterTypeHints = true,
							includeInlayVariableTypeHints = true,
							includeInlayPropertyDeclarationTypeHints = true,
							includeInlayFunctionLikeReturnTypeHints = true,
							includeInlayEnumMemberValueHints = true,
						},
					},
				},
			}

			-- ═══════════════════════════════════════════════════════════════════════════
			-- DOCKER
			-- ═══════════════════════════════════════════════════════════════════════════
			opts.servers.dockerls = {
				settings = {
					docker = {
						languageserver = {
							formatter = {
								ignoreMultilineInstructions = true,
							},
						},
					},
				},
			}

			opts.servers.docker_compose_language_service = {
				filetypes = { "yaml.docker-compose" },
			}

			-- ═══════════════════════════════════════════════════════════════════════════
			-- MARKDOWN
			-- ═══════════════════════════════════════════════════════════════════════════
			opts.servers.marksman = {
				filetypes = { "markdown", "markdown.mdx" },
			}

			-- ═══════════════════════════════════════════════════════════════════════════
			-- BASH/SHELL
			-- ═══════════════════════════════════════════════════════════════════════════
			opts.servers.bashls = {
				settings = {
					bashIde = {
						globPattern = "*@(.sh|.inc|.bash|.command)",
					},
				},
			}

			-- ═══════════════════════════════════════════════════════════════════════════
			-- LUA (for Neovim configuration)
			-- ═══════════════════════════════════════════════════════════════════════════
			opts.servers.lua_ls = {
				settings = {
					Lua = {
						workspace = {
							checkThirdParty = false,
						},
						completion = {
							callSnippet = "Replace",
						},
						diagnostics = {
							globals = { "vim" },
						},
						telemetry = { enable = false },
						hint = {
							enable = true, -- Available when you toggle on
							arrayIndex = "Auto",
							await = true,
							paramName = "All",
							paramType = true,
							semicolon = "All",
							setType = false,
						},
					},
				},
			}

			-- ═══════════════════════════════════════════════════════════════════════════
			-- SQL
			-- ═══════════════════════════════════════════════════════════════════════════
			opts.servers.sqls = {
				settings = {
					sqls = {
						connections = {},
					},
				},
			}

			-- ═══════════════════════════════════════════════════════════════════════════
			-- TOML
			-- ═══════════════════════════════════════════════════════════════════════════
			opts.servers.taplo = {
				filetypes = { "toml" },
			}

			-- ═══════════════════════════════════════════════════════════════════════════
			-- XML
			-- ═══════════════════════════════════════════════════════════════════════════
			opts.servers.lemminx = {
				filetypes = { "xml", "xsd", "xsl", "xslt", "svg" },
			}

			-- ═══════════════════════════════════════════════════════════════════════════
			-- MATLAB
			-- ═══════════════════════════════════════════════════════════════════════════
			opts.servers.matlab_ls = {
				settings = {
					MATLAB = {
						indexWorkspace = false,
						installPath = "/usr/local/MATLAB/R2024b",
						matlabConnectionTiming = "onStart",
						telemetry = false,
					},
				},
			}

			-- ═══════════════════════════════════════════════════════════════════════════
			-- GLOBAL DIAGNOSTIC SETTINGS
			-- ═══════════════════════════════════════════════════════════════════════════
			opts.diagnostics = opts.diagnostics or {}
			opts.diagnostics = vim.tbl_deep_extend("force", opts.diagnostics, {
				underline = true,
				update_in_insert = false,
				virtual_text = {
					spacing = 4,
					source = "if_many",
					prefix = "●",
				},
				severity_sort = true,
				signs = {
					text = {
						[vim.diagnostic.severity.ERROR] = " ",
						[vim.diagnostic.severity.WARN] = " ",
						[vim.diagnostic.severity.HINT] = " ",
						[vim.diagnostic.severity.INFO] = " ",
					},
				},
			})

			-- ═══════════════════════════════════════════════════════════════════════════
			-- SETUP HANDLERS
			-- ═══════════════════════════════════════════════════════════════════════════
			opts.setup = opts.setup or {}

			opts.setup["*"] = function(server, server_opts)
				require("lspconfig")[server].setup(server_opts)
			end

			return opts
		end,
	},

	-- ═══════════════════════════════════════════════════════════════════════════
	-- SCHEMASTORE - JSON/YAML schema support
	-- ═══════════════════════════════════════════════════════════════════════════
	{
		"b0o/schemastore.nvim",
		lazy = true,
		version = false,
	},
}
