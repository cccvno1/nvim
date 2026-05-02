return {
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      signs = {
        add = { text = "+" },
        change = { text = "~" },
        delete = { text = "_" },
        topdelete = { text = "‾" },
        changedelete = { text = "~" },
      },
      on_attach = function(bufnr)
        local map = vim.keymap.set
        local opts = function(desc)
          return { buffer = bufnr, desc = desc }
        end

        map("n", "]h", function() package.loaded.gitsigns.nav_hunk("next") end, opts("Next hunk"))
        map("n", "[h", function() package.loaded.gitsigns.nav_hunk("prev") end, opts("Previous hunk"))
        map("n", "<leader>hp", function() package.loaded.gitsigns.preview_hunk() end, opts("Preview hunk"))
        map("n", "<leader>hr", function() package.loaded.gitsigns.reset_hunk() end, opts("Reset hunk"))
      end,
    },
  },
  {
    "sindrets/diffview.nvim",
    cmd = {
      "DiffviewOpen",
      "DiffviewClose",
      "DiffviewFileHistory",
      "DiffviewToggleFiles",
      "DiffviewFocusFiles",
    },
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    opts = {
      enhanced_diff_hl = true,
      view = {
        default = {
          layout = "diff2_horizontal",
        },
        merge_tool = {
          layout = "diff3_horizontal",
        },
      },
    },
  },
  {
    "folke/trouble.nvim",
    cmd = "Trouble",
    opts = {},
  },
  {
    "stevearc/aerial.nvim",
    cmd = { "AerialToggle", "AerialOpen" },
    opts = function()
      local bigfile = require("cccvno1.core.bigfile").defaults
      return {
        backends = { "lsp", "treesitter", "markdown", "man" },
        disable_max_lines = bigfile.lines,
        disable_max_size = bigfile.size,
      }
    end,
  },
  {
    "stevearc/quicker.nvim",
    event = "FileType qf",
    opts = {},
  },
}
