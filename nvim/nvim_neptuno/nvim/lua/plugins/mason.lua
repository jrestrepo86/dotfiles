return {
  {
    "williamboman/mason.nvim",
    opts = {
      ensure_installed = {
        "prettier",
        'eslint_d',
        -- python
        "pyright",
        "isort",
        "ruff",
        "black",
        "pylint",
        "debugpy",
        "django-template-lsp",
        "djlint",
        -- latex
        "latexindent",
        "texlab",
        "bibtex-tidy",
        "tex-fmt",
        -- lua
        "stylua",
        "selene",
        "luacheck",
        -- json
        "json-lsp",
        -- yaml
        "yamllint",
        "yaml-language-server",
        "yamlfmt",
        "yamlfix",
        -- markdown
        "markdownlint-cli2",
        "markdown-toc",
        -- shell
        "shellcheck",
        "shfmt",
        "bash-language-server",
        -- matlab
        "matlab-language-server",
        -- xml
        "xmlformatter",
        -- dockerfile
        "dockerfile-language-server",
        "docker-compose-language-service",
        "hadolint",
        -- typescript
        "js-debug-adapter",
        "typescript-language-server",
        -- html
        "html-lsp",
        "jinja-lsp",
        -- css
        "tailwindcss-language-server",
        "css-lsp",
        -- sql
        "sqls",
        "sql-formatter",
      },
    },
  },
}
