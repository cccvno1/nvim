return {
  {
    "folke/sidekick.nvim",
    cmd = "Sidekick",
    dependencies = {
      "zbirenbaum/copilot.lua",
      "ibhagwan/fzf-lua",
    },
    config = function()
      require("cccvno1.ai.sidekick").setup()
    end,
  },
}
