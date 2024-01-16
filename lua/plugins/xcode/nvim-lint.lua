---@diagnostic disable: missing-fields
local cachedConfig = nil
local searchedForConfig = false

local function find_config()
  if searchedForConfig then
    return cachedConfig
  end

  -- find .swiftlint.yml config file in the working directory
  -- could be simplified if you keep it always in the root directory
  local swiftlintConfigs = vim.fn.systemlist({
    "find",
    vim.fn.getcwd(),
    "-maxdepth",
    "2", -- if you need you can set higher number
    "-iname",
    ".swiftlint.yml",
    "-not",
    "-path",
    "*/.*/*",
  })
  searchedForConfig = true

  if vim.v.shell_error ~= 0 then
    return nil
  end

  table.sort(swiftlintConfigs, function(a, b)
    return a ~= "" and #a < #b
  end)

  if swiftlintConfigs[1] then
    cachedConfig = string.match(swiftlintConfigs[1], "^%s*(.-)%s*$")
  end

  return cachedConfig
end

local function setup_swiftlint()
  local lint = require("lint")
  local pattern = "[^:]+:(%d+):(%d+): (%w+): (.+)"
  local groups = { "lnum", "col", "severity", "message" }
  local defaults = { ["source"] = "swiftlint" }
  local severity_map = {
    ["error"] = vim.diagnostic.severity.ERROR,
    ["warning"] = vim.diagnostic.severity.WARN,
  }

  lint.linters.swiftlint = {
    cmd = "swiftlint",
    stdin = true,
    args = {
      "lint",
      "--use-stdin",
      "--config",
      function()
        return find_config() or os.getenv("HOME") .. "/.config/nvim/.swiftlint.yml"
      end,
      "-",
    },
    stream = "stdout",
    ignore_exitcode = true,
    parser = require("lint.parser").from_pattern(pattern, groups, severity_map, defaults),
  }
end

return {
  {
    "mfussenegger/nvim-lint",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      local lint = require("lint")

      -- setup
      setup_swiftlint()
      lint.linters_by_ft = {
        swift = { "swiftlint" },
      }

      local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })

      vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPost", "InsertLeave", "TextChanged" }, {
        group = lint_augroup,
        callback = function()
          require("lint").try_lint()
        end,
      })

      vim.keymap.set("n", "<leader>ml", function()
        require("lint").try_lint()
      end, { desc = "Lint file" })
    end,
  },

  {
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
  },
}
