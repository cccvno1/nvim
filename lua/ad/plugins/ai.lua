return {
  {
    "folke/sidekick.nvim",
    cmd = "Sidekick",
    dependencies = {
      "zbirenbaum/copilot.lua",
      "ibhagwan/fzf-lua",
    },
    config = function()
      require("ad.ai.sidekick").setup()
    end,
  },
}
