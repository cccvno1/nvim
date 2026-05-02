return {
  {
    "romgrk/barbar.nvim",
    event = "VeryLazy",
    dependencies = {
      "lewis6991/gitsigns.nvim",
      "echasnovski/mini.icons",
    },
    init = function()
      vim.g.barbar_auto_setup = false
    end,
    opts = {
      animation = false,
      clickable = true,
      focus_on_close = "left",
      icons = {
        button = "x",
        modified = { button = "*" },
        pinned = { button = "P", filename = true },
        diagnostics = {
          { enabled = true, icon = "E" },
          { enabled = true, icon = "W" },
        },
        gitsigns = {
          added = { enabled = true, icon = "+" },
          changed = { enabled = true, icon = "~" },
          deleted = { enabled = true, icon = "-" },
        },
      },
      sidebar_filetypes = {
        oil = { text = "Oil", align = "center" },
      },
    },
    config = function(_, opts)
      require("barbar").setup(opts)
    end,
  },
}
