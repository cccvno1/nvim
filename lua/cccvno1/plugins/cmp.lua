return {
  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    event = "InsertEnter",
    opts = {
      suggestion = { enabled = false },
      panel = { enabled = false },
      should_attach = function(bufnr, _)
        return not vim.b[bufnr].bigfile
      end,
    },
  },
  {
    "saghen/blink.cmp",
    version = "1.*",
    event = { "InsertEnter", "CmdlineEnter" },
    dependencies = {
      "fang2hou/blink-copilot",
    },
    opts = {
      keymap = { preset = "default" },
      completion = { documentation = { auto_show = true, auto_show_delay_ms = 300 } },
      sources = {
        default = function()
          if vim.b.bigfile or vim.b.completion == false then
            return { "buffer", "path" }
          end
          return { "lsp", "path", "buffer", "copilot" }
        end,
        providers = {
          copilot = {
            name = "copilot",
            module = "blink-copilot",
            score_offset = 100,
            async = true,
          },
        },
      },
    },
  },
}
