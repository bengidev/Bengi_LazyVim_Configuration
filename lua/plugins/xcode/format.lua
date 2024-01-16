local cachedConfig = nil
local searchedForConfig = false

local function find_config()
  if searchedForConfig then
    return cachedConfig
  end

  -- find .swiftformat config file in the working directory
  -- could be simplified if you keep it always in the root directory
  local swiftFormatConfigs = vim.fn.systemlist({
    "find",
    vim.fn.getcwd(),
    "-maxdepth",
    "2", -- if you need you can set higher number
    "-iname",
    ".swiftformat",
    "-not",
    "-path",
    "*/.*/*",
  })
  searchedForConfig = true

  if vim.v.shell_error ~= 0 then
    return nil
  end

  table.sort(swiftFormatConfigs, function(a, b)
    return a ~= "" and #a < #b
  end)

  if swiftFormatConfigs[1] then
    cachedConfig = string.match(swiftFormatConfigs[1], "^%s*(.-)%s*$")
  end

  return cachedConfig
end

return {
  "stevearc/conform.nvim",
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    local conform = require("conform")

    conform.setup({
      formatters_by_ft = {
        swift = { "swiftformat_ext" },
      },
      format_on_save = function(bufnr)
        return { timeout_ms = 500, lsp_fallback = true }
      end,
      log_level = vim.log.levels.ERROR,
      formatters = {
        swiftformat_ext = {
          command = "swiftformat",
          args = function()
            return {
              "--config",
              find_config() or "~/.config/nvim/.swiftformat", -- update fallback path if needed
              "--stdinpath",
              "$FILENAME",
            }
          end,
          range_args = function(ctx)
            return {
              "--config",
              find_config() or "~/.config/nvim/.swiftformat", -- update fallback path if needed
              "--linerange",
              ctx.range.start[1] .. "," .. ctx.range["end"][1],
            }
          end,
          stdin = true,
          condition = function(ctx)
            return vim.fs.basename(ctx.filename) ~= "README.md"
          end,
        },
      },
    })

    vim.keymap.set({ "n", "v" }, "<leader>mp", function()
      conform.format({
        lsp_fallback = true,
        async = false,
        timeout_ms = 500,
      })
    end, { desc = "Format file or range (in visual mode)" })
  end,
}
