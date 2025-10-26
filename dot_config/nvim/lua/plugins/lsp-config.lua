-- Complete LSP configuration for all languages
-- Python: basedpyright configured to NOT remove unused imports
-- LaTeX: ltex with English + Spanish support
-- Safe handling of schemastore

return {
	{
		"neovim/nvim-lspconfig",
		opts = {
			-- Automatic server setup
			servers = {
				-- ========================================
				-- PYTHON
				-- ========================================
				basedpyright = {
					settings = {
						basedpyright = {
							analysis = {
								typeCheckingMode = "basic", -- "off" | "basic" | "strict"
								autoSearchPaths = true,
								useLibraryCodeForTypes = true,
								diagnosticMode = "workspace", -- "openFilesOnly" | "workspace"
								autoImportCompletions = true,

								-- CRITICAL: Don't report unused imports/variables
								diagnosticSeverityOverrides = {
									reportUnusedImport = "none", -- Don't report unused imports
									reportUnusedVariable = "none", -- Don't report unused variables
									reportUnusedClass = "none",
									reportUnusedFunction = "none",
								},

								-- Other useful settings
								stubPath = vim.fn.stdpath("data") .. "/lazy/python-type-stubs",
							},
						},
					},
				},

				-- Ruff LSP (alternative to basedpyright for some features)
				ruff_lsp = {
					on_attach = function(client, bufnr)
						-- Disable hover in favor of basedpyright
						client.server_capabilities.hoverProvider = false
					end,
					init_options = {
						settings = {
							-- Ruff args - IGNORE F401 (unused imports)
							args = {
								"--ignore=F401", -- unused imports
								"--ignore=F403", -- star imports (optional)
							},
						},
					},
				},

				-- ========================================
				-- LATEX
				-- ========================================
				texlab = {
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
				},

				-- Grammar & Spelling - ENGLISH + SPANISH
				ltex = {
					settings = {
						ltex = {
							-- Enable both languages
							language = "en-US", -- Default language
							additionalRules = {
								enablePickyRules = true,
								motherTongue = "es", -- Spanish as mother tongue
							},

							-- Language-specific settings
							["ltex-ls"] = {
								logLevel = "warning",
							},

							-- Enable specific checks
							enabled = {
								"latex",
								"markdown",
								"restructuredtext",
							},

							-- Custom dictionaries per language
							dictionary = {
								["en-US"] = {
									-- Add technical terms, acronyms, etc.
									"LaTeX",
									"BibTeX",
									"Neovim",
									"Django",
									"Python",
									"NumPy",
									"Matplotlib",
									"PyTorch",
									"sklearn",
								},
								["es"] = {
									-- Términos técnicos en español
									"software",
									"hardware",
									"internet",
								},
							},

							-- Disabled rules (if needed)
							disabledRules = {
								["en-US"] = { "MORFOLOGIK_RULE_EN_US" },
								["es"] = {},
							},

							-- Language detection
							languageToolHttpServerUri = "",
							languageToolOrg = {
								username = "",
								apiKey = "",
							},
						},
					},
					filetypes = { "tex", "latex", "markdown", "rst" },
				},

				-- ========================================
				-- WEB DEVELOPMENT (Django, HTML, CSS)
				-- ========================================
				html = {
					filetypes = { "html", "htmldjango" },
				},

				cssls = {
					settings = {
						css = {
							validate = true,
							lint = {
								unknownAtRules = "ignore", -- For Tailwind
							},
						},
						scss = {
							validate = true,
						},
					},
				},

				tailwindcss = {
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
				},

				emmet_ls = {
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
				},

				-- ========================================
				-- JAVASCRIPT/TYPESCRIPT
				-- ========================================
				tsserver = {
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
				},

				-- ========================================
				-- DATA FORMATS
				-- ========================================
				jsonls = {
					-- Safe handling of schemastore
					settings = function()
						local has_schemastore, schemastore = pcall(require, "schemastore")
						if has_schemastore then
							return {
								json = {
									schemas = schemastore.json.schemas(),
									validate = { enable = true },
								},
							}
						else
							return {
								json = {
									validate = { enable = true },
								},
							}
						end
					end,
				},

				yamlls = {
					-- Safe handling of schemastore
					settings = function()
						local has_schemastore, schemastore = pcall(require, "schemastore")
						if has_schemastore then
							return {
								yaml = {
									schemas = schemastore.yaml.schemas(),
									schemaStore = {
										enable = true,
										url = "https://www.schemastore.org/api/json/catalog.json",
									},
									format = {
										enable = true,
									},
									validate = true,
								},
							}
						else
							return {
								yaml = {
									schemaStore = {
										enable = true,
										url = "https://www.schemastore.org/api/json/catalog.json",
									},
									format = {
										enable = true,
									},
									validate = true,
								},
							}
						end
					end,
				},

				taplo = {
					-- TOML LSP
					filetypes = { "toml" },
				},

				-- ========================================
				-- DOCKER
				-- ========================================
				dockerls = {
					-- Dockerfile LSP
					settings = {
						docker = {
							languageserver = {
								formatter = {
									ignoreMultilineInstructions = true,
								},
							},
						},
					},
				},

				docker_compose_language_service = {
					-- Docker Compose LSP
					filetypes = { "yaml.docker-compose" },
				},

				-- ========================================
				-- MARKDOWN
				-- ========================================
				marksman = {
					-- Markdown LSP
					filetypes = { "markdown", "markdown.mdx" },
				},

				-- ========================================
				-- BASH
				-- ========================================
				bashls = {
					settings = {
						bashIde = {
							globPattern = "*@(.sh|.inc|.bash|.command)",
						},
					},
				},

				-- ========================================
				-- LUA (for Neovim config)
				-- ========================================
				lua_ls = {
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
						},
					},
				},

				-- ========================================
				-- SQL
				-- ========================================
				sqls = {
					settings = {
						sqls = {
							connections = {
								-- Add your database connections
								-- {
								--   driver = "postgresql",
								--   dataSourceName = "host=localhost port=5432 user=postgres dbname=mydb sslmode=disable",
								-- }
							},
						},
					},
				},

				-- ========================================
				-- XML
				-- ========================================
				lemminx = {
					-- XML LSP
					filetypes = { "xml", "xsd", "xsl", "xslt", "svg" },
				},
			},

			-- Global diagnostic settings
			diagnostics = {
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
			},
		},
	},

	-- Schema store for JSON/YAML (optional but recommended)
	{
		"b0o/schemastore.nvim",
		lazy = true,
		version = false,
	},
}
