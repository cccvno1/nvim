return {
  {
    "romus204/tree-sitter-manager.nvim",
    cmd = "TSManager",
    event = { "BufReadPost", "BufNewFile" },
    opts = function()
      return {
        ensure_installed = require("cccvno1.core.treesitter").parsers,
        auto_install = false,
        highlight = true,
      }
    end,
  },
  {
    "windwp/nvim-ts-autotag",
    event = "VeryLazy",
    opts = {
      opts = { enable_close = true, enable_rename = true, enable_close_on_slash = false },
    },
  },
}
