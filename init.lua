vim.g.mapleader = " "
vim.g.maplocalleader = " "

require("cccvno1.bootstrap")
require("cccvno1.options")
require("cccvno1.autocmds")
require("cccvno1.keymaps")

require("lazy").setup({
  { import = "cccvno1.plugins" },
}, {
  checker = { enabled = true, notify = false },
  change_detection = { notify = false },
  install = { colorscheme = { "kanagawa" } },
  rocks = { enabled = false },
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
