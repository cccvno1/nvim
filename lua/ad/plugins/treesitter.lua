return {
  {
    "romus204/tree-sitter-manager.nvim",
    cmd = "TSManager",
    opts = {},
  },
  {
    "windwp/nvim-ts-autotag",
    event = "VeryLazy",
    opts = {
      opts = { enable_close = true, enable_rename = true, enable_close_on_slash = false },
    },
  },
}
