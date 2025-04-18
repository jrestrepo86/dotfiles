return {
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        python = { "isort", "black" },
        json = { "prettier" },
        css = { "prettier" },
        scss = { "prettier" },
        html = { "prettier" },
        yaml = { "yamlfmt" },
        markdown = { "prettier" },
        lua = { "stylua" },
        xml = { "xmlformatter" },
        htmldjango = { "djlint" },
        tex = { "latexindent" },
        sql = { "sql_formatter" },
      },
    },
  },
}
