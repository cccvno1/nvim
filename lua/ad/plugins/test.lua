local function run_neotest(scope)
  if vim.b.bigfile then
    vim.notify("Tests disabled for big files", vim.log.levels.WARN, { title = "Neotest" })
    return
  end

  require("lazy").load({ plugins = { "neotest" } })
  if scope == "file" then
    require("neotest").run.run(vim.fn.expand("%"))
  else
    require("neotest").run.run()
  end
end

return {
  {
    "nvim-neotest/neotest",
    dependencies = {
      "nvim-neotest/nvim-nio",
      "nvim-lua/plenary.nvim",
      "antoinemadec/FixCursorHold.nvim",
      "nvim-neotest/neotest-python",
      "nvim-neotest/neotest-go",
      "nvim-neotest/neotest-jest",
      "marilari88/neotest-vitest",
      "nvim-neotest/neotest-plenary",
      "alfaix/neotest-gtest",
    },
    init = function()
      vim.keymap.set("n", "<leader>tt", function()
        run_neotest()
      end, { desc = "Run nearest test" })
      vim.keymap.set("n", "<leader>tf", function()
        run_neotest("file")
      end, { desc = "Run file tests" })
    end,
    keys = {
      { "<leader>ts", function() require("neotest").summary.toggle() end, desc = "Test summary" },
    },
    config = function()
      local function add_adapter(adapters, name, adapter)
        local ok, result = pcall(adapter)
        if ok then
          table.insert(adapters, result)
        else
          vim.notify(("Skipping %s: %s"):format(name, result), vim.log.levels.WARN)
        end
      end

      local adapters = {}
      add_adapter(adapters, "neotest-python", function()
        return require("neotest-python")({})
      end)
      add_adapter(adapters, "neotest-go", function()
        return require("neotest-go")
      end)
      add_adapter(adapters, "neotest-jest", function()
        return require("neotest-jest")({})
      end)
      add_adapter(adapters, "neotest-vitest", function()
        return require("neotest-vitest")({})
      end)
      add_adapter(adapters, "neotest-plenary", function()
        return require("neotest-plenary")
      end)
      add_adapter(adapters, "neotest-gtest", function()
        return require("neotest-gtest").setup({})
      end)

      require("neotest").setup({
        adapters = adapters,
        consumers = {
          ad_test_output = require("ad.ai.contexts.test").neotest_consumer,
        },
      })
    end,
  },
  {
    "stevearc/overseer.nvim",
    cmd = { "OverseerRun", "OverseerToggle", "OverseerInfo" },
    keys = {
      { "<leader>wr", "<cmd>OverseerRun<cr>", desc = "Run task" },
      { "<leader>wt", "<cmd>OverseerToggle<cr>", desc = "Tasks" },
    },
    opts = { dap = false },
  },
}
