---@diagnostic disable: unused-local

local utils = require("plugins.utils.shared")

return {
  "stevearc/conform.nvim",
  event = { "BufReadPre", "BufNewFile" },
  keys = {
    -- Customize or remove this keymap to your liking
    vim.keymap.set({ "n", "v" }, "<leader>mp", function()
      require("conform").format({
        lsp_fallback = true,
        async = false,
        timeout_ms = 500,
      })
    end, { desc = "Format file or range (in visual mode)" }),
  },
  -- Everything in opts will be passed to setup()
  opts = {
    -- Define your formatters
    formatters_by_ft = {
      json = { "fixjson" },
      lua = { "stylua" },
      java = { "google-java-format" },
      swift = { "swiftformat_ext" },
    },
    -- Customize formatters
    formatters = {
      swiftformat_ext = {
        command = "swiftformat",
        args = function(self, ctx)
          return {
            "--config",
            utils.find_config(".swiftformat") or os.getenv("HOME") .. "/.config/nvim/.swiftformat", -- change path if needed
            "--stdinpath",
            "$FILENAME",
          }
        end,
        range_args = function(self, ctx)
          return {
            "--config",
            utils.find_config(".swiftformat") or os.getenv("HOME") .. "/.config/nvim/.swiftformat", -- change path if needed
            "--linerange",
            ctx.range.start[1] .. "," .. ctx.range["end"][1],
          }
        end,
        stdin = true,
        condition = function(self, ctx)
          return vim.fs.basename(ctx.filename) ~= "README.md"
        end,
      },
    },
  },
}
