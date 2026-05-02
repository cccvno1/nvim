return {
  {
    "rebelot/kanagawa.nvim",
    lazy = false,
    priority = 1000,
    opts = {
      compile = false,
      dimInactive = false,
      terminalColors = true,
    },
    config = function(_, opts)
      require("kanagawa").setup(opts)
      vim.cmd.colorscheme("kanagawa")
    end,
  },
  {
    "echasnovski/mini.icons",
    version = false,
    lazy = false,
    config = function()
      local icons = require("mini.icons")
      icons.setup()
      icons.mock_nvim_web_devicons()
    end,
  },
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    keys = {
      {
        "<leader>?",
        function()
          require("which-key").show({ global = false })
        end,
        desc = "Buffer local keymaps",
      },
    },
    opts = {
      preset = "modern",
      spec = {
        { "<leader>a", group = "ai" },
        { "<leader>b", group = "buffers" },
        { "<leader>c", group = "code" },
        { "<leader>d", group = "debug" },
        { "<leader>f", group = "find" },
        { "<leader>g", group = "git" },
        { "<leader>h", group = "hunks" },
        { "<leader>m", group = "markdown" },
        { "<leader>q", group = "quit" },
        { "<leader>s", group = "search" },
        { "<leader>t", group = "tests" },
        { "<leader>u", group = "ui" },
        { "<leader>w", group = "work" },
        { "<leader>x", group = "diagnostics" },
      },
    },
  },
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    opts = function()
      local ui = require("cccvno1.core.ui")
      return {
        options = {
          theme = "kanagawa",
          globalstatus = true,
          component_separators = "",
          section_separators = "",
        },
        sections = {
          lualine_a = { "mode" },
          lualine_b = { "branch", "diff" },
          lualine_c = { { "filename", path = 1 } },
          lualine_x = { ui.bigfile_status, "diagnostics", "encoding", "filetype" },
          lualine_y = { "progress" },
          lualine_z = { "location" },
        },
      }
    end,
  },
  {
    "j-hui/fidget.nvim",
    event = "LspAttach",
    opts = {},
  },
}
