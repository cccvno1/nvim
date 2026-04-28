return {
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      "rcarriga/nvim-dap-ui",
      "nvim-neotest/nvim-nio",
      "theHamsta/nvim-dap-virtual-text",
      "jay-babu/mason-nvim-dap.nvim",
      "Weissle/persistent-breakpoints.nvim",
      "leoluz/nvim-dap-go",
      "mfussenegger/nvim-dap-python",
    },
    cmd = {
      "DapContinue",
      "DapToggleBreakpoint",
      "DapTerminate",
      "DapStepOver",
      "DapStepInto",
      "DapStepOut",
    },
    keys = {
      { "<F5>", function() require("dap").continue() end, desc = "DAP continue" },
      { "<F10>", function() require("dap").step_over() end, desc = "DAP step over" },
      { "<F11>", function() require("dap").step_into() end, desc = "DAP step into" },
      { "<F12>", function() require("dap").step_out() end, desc = "DAP step out" },
      { "<leader>db", function() require("persistent-breakpoints.api").toggle_breakpoint() end, desc = "Toggle breakpoint" },
      { "<leader>du", function() require("dapui").toggle() end, desc = "DAP UI" },
    },
    config = function()
      local dap = require("dap")
      local dapui = require("dapui")

      require("mason-nvim-dap").setup({
        ensure_installed = { "python", "delve", "js", "codelldb" },
        automatic_installation = true,
        handlers = {},
      })
      dapui.setup()
      require("nvim-dap-virtual-text").setup({
        enabled = not vim.b.bigfile,
        display_callback = function(variable, buf, _stackframe, _node, options)
          if vim.b[buf].bigfile then
            return nil
          end

          if options.virt_text_pos == "inline" then
            return " = " .. variable.value:gsub("%s+", " ")
          end

          return variable.name .. " = " .. variable.value:gsub("%s+", " ")
        end,
      })
      require("persistent-breakpoints").setup({ load_breakpoints_event = { "BufReadPost" } })
      require("dap-go").setup()

      local python = vim.fn.stdpath("data") .. "/mason/packages/debugpy/venv/bin/python"
      require("dap-python").setup(python)

      local js_debug = vim.fn.stdpath("data") .. "/mason/packages/js-debug-adapter/js-debug/src/dapDebugServer.js"
      if vim.uv.fs_stat(js_debug) then
        local js_adapter = {
          type = "server",
          host = "localhost",
          port = "${port}",
          executable = {
            command = "node",
            args = { js_debug, "${port}" },
          },
        }

        for _, adapter in ipairs({ "pwa-node", "pwa-chrome", "pwa-msedge", "node-terminal", "pwa-extensionHost" }) do
          dap.adapters[adapter] = js_adapter
        end

        for _, language in ipairs({ "javascript", "javascriptreact", "typescript", "typescriptreact" }) do
          dap.configurations[language] = dap.configurations[language] or {}
          vim.list_extend(dap.configurations[language], {
            {
              type = "pwa-node",
              request = "launch",
              name = "Launch file",
              program = "${file}",
              cwd = "${workspaceFolder}",
            },
            {
              type = "pwa-node",
              request = "attach",
              name = "Attach process",
              processId = require("dap.utils").pick_process,
              cwd = "${workspaceFolder}",
            },
            {
              type = "pwa-chrome",
              request = "launch",
              name = "Launch Chrome",
              url = "http://localhost:3000",
              webRoot = "${workspaceFolder}",
            },
          })
        end
      else
        vim.notify("Skipping JS DAP setup: js-debug-adapter is not installed", vim.log.levels.WARN)
      end

      dap.listeners.after.event_initialized.dapui_config = function()
        dapui.open()
      end
      dap.listeners.before.event_terminated.dapui_config = function()
        dapui.close()
      end
      dap.listeners.before.event_exited.dapui_config = function()
        dapui.close()
      end
    end,
  },
}
