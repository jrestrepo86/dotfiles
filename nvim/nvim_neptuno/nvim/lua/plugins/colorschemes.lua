return {
  {
    "vague2k/huez.nvim",
    dependencies = { "nvim-telescope/telescope.nvim" },
    -- if you want registry related features, uncomment this
    -- import = "huez-manager.import"
    branch = "stable",
    event = "UIEnter",
    config = function()
      require("huez").setup({})
    end,
  },
  { "e-q/okcolors.nvim",                name = "okcolors", lazy = false },
  { 'embark-theme/vim',                 lazy = false },
  { "Skardyy/makurai-nvim",             lazy = false },
  { "rjshkhr/shadow.nvim",              lazy = false },
  { "EdenEast/nightfox.nvim",           lazy = false },
  { "mistweaverco/retro-theme.nvim",    lazy = false },
  { "nyoom-engineering/oxocarbon.nvim", lazy = false },
  { "joshdick/onedark.vim",             lazy = false },
  { "tiagovla/tokyodark.nvim",          lazy = false },
  {
    "craftzdog/solarized-osaka.nvim",
    lazy = false,
    priority = 1000,
    opts = function()
      return {
        transparent = true,
      }
    end,
  },
  {
    "catppuccin/nvim",
    lazy = false,
    name = "catppuccin",
    opts = {
      integrations = {
        aerial = true,
        alpha = true,
        cmp = true,
        dashboard = true,
        flash = true,
        gitsigns = true,
        headlines = true,
        illuminate = true,
        indent_blankline = { enabled = true },
        leap = true,
        lsp_trouble = true,
        mason = true,
        markdown = true,
        mini = true,
        native_lsp = {
          enabled = true,
          underlines = {
            errors = { "undercurl" },
            hints = { "undercurl" },
            warnings = { "undercurl" },
            information = { "undercurl" },
          },
        },
        navic = { enabled = true, custom_bg = "lualine" },
        neotest = true,
        neotree = true,
        noice = true,
        notify = true,
        semantic_tokens = true,
        telescope = true,
        treesitter = true,
        treesitter_context = true,
        which_key = true,
      },
    },
  },
}
