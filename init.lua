vim.g.mapleader = " "
vim.g.maplocalleader = " "

require("ad.bootstrap")
require("ad.options")
require("ad.autocmds")
require("ad.keymaps")

require("lazy").setup({
  { import = "ad.plugins" },
}, {
  checker = { enabled = true, notify = false },
  change_detection = { notify = false },
  install = { colorscheme = { "kanagawa" } },
  ui = { border = "rounded" },
  performance = {
    rtp = {
      disabled_plugins = {
        "gzip",
        "matchit",
        "matchparen",
        "netrwPlugin",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
      },
    },
  },
})
