---@diagnostic disable: missing-fields
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
  "mfussenegger/nvim-lint",
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    local lint = require("lint")

    -- swiftlint
    local pattern = "[^:]+:(%d+):(%d+): (%w+): (.+)"
    local groups = { "lnum", "col", "severity", "message" }
    local defaults = { ["source"] = "swiftlint" }
    local severity_map = {
      ["error"] = vim.diagnostic.severity.ERROR,
      ["warning"] = vim.diagnostic.severity.WARN,
    }

    lint.linters.swiftlint = {
      cmd = "swiftlint",
      stdin = false,
      args = {
        "lint",
        "--force-exclude",
        "--use-alternative-excluding",
        "--config",
        function()
          return find_config(".swiftlint.yml") or os.getenv("HOME") .. "/.config/nvim/.swiftlint.yml" -- change path if needed
        end,
      },
      stream = "stdout",
      ignore_exitcode = true,
      parser = require("lint.parser").from_pattern(pattern, groups, severity_map, defaults),
    }

    -- setup
    lint.linters_by_ft = {
      swift = { "swiftlint" },
    }

    local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })

    vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPost" }, {
      group = lint_augroup,
      callback = function()
        require("lint").try_lint()
      end,
    })

    vim.keymap.set("n", "<leader>ml", function()
      require("lint").try_lint()
    end, { desc = "Lint file" })
  end,
}
