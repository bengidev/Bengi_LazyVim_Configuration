local cachedConfig = {}
local searchedForConfig = {}

local function find_config(filename)
  if searchedForConfig[filename] then
    return cachedConfig[filename]
  end

  local configs = vim.fn.systemlist({
    "find",
    vim.fn.getcwd(),
    "-maxdepth",
    "2",
    "-iname",
    filename,
    "-not",
    "-path",
    "*/.*/*",
  })
  searchedForConfig[filename] = true

  if vim.v.shell_error ~= 0 then
    return nil
  end

  table.sort(configs, function(a, b)
    return a ~= "" and #a < #b
  end)

  if configs[1] then
    cachedConfig[filename] = string.match(configs[1], "^%s*(.-)%s*$")
  end

  return cachedConfig[filename]
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
              find_config(".swiftformat") or "~/.config/nvim/.swiftformat", -- update fallback path if needed
              "--stdinpath",
              "$FILENAME",
            }
          end,
          range_args = function(ctx)
            return {
              "--config",
              utils.find_config(".swiftformat") or "~/.config/nvim/.swiftformat", -- update fallback path if needed
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
