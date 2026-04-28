return {
  {
    "folke/flash.nvim",
    event = "VeryLazy",
    opts = {},
  },
  { "echasnovski/mini.ai", version = false, event = "VeryLazy", opts = {} },
  { "echasnovski/mini.surround", version = false, event = "VeryLazy", opts = {} },
  { "echasnovski/mini.pairs", version = false, event = "InsertEnter", opts = {} },
  {
    "numToStr/Comment.nvim",
    event = "VeryLazy",
    opts = {},
  },
  {
    "folke/todo-comments.nvim",
    event = "VeryLazy",
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {},
  },
}
