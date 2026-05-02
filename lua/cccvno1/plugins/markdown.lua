return {
  {
    "MeanderingProgrammer/render-markdown.nvim",
    ft = { "markdown", "Avante", "codecompanion" },
    dependencies = { "echasnovski/mini.icons" },
    opts = {
      enabled = true,
      latex = { enabled = false },
      ignore = function(buf)
        return vim.b[buf].bigfile == true
      end,
    },
    config = function(_, opts)
      require("render-markdown").setup(opts)
    end,
  },
  {
    "brianhuster/live-preview.nvim",
    ft = { "markdown", "html", "svg" },
    cmd = { "LivePreview", "LivePreviewClose", "LivePreviewToggle" },
    opts = {},
    init = function()
      package.preload["live-preview"] = function()
        return require("livepreview")
      end
    end,
    config = function(_, opts)
      require("livepreview.config").set(opts)

      vim.api.nvim_create_user_command("LivePreviewClose", function()
        require("livepreview").close()
      end, {})

      vim.api.nvim_create_user_command("LivePreviewToggle", function()
        local preview = require("livepreview")

        if preview.is_running() then
          preview.close()
        else
          vim.cmd.LivePreview("start")
        end
      end, {})
    end,
  },
}
