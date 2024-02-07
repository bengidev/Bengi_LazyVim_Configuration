-- Configure lsp for support Swift language
-- Loads the Swift lsp from inside XCode
--

return {
  "neovim/nvim-lspconfig",
  lazy = false,
  event = { "BufReadPre", "BufNewFile" },
  dependencies = {
    "hrsh7th/cmp-nvim-lsp",
    { "antosha417/nvim-lsp-file-operations", config = true },
  },
  opts = {
    servers = {
      sourcekit = {
        root_dir = function(filename, _)
          local util = require("lspconfig.util")

          return util.root_pattern("buildServer.json")(filename)
            or util.root_pattern("*.xcodeproj", "*.xcworkspace")(filename)
            or util.find_git_ancestor(filename)
            or util.root_pattern("Package.swift")(filename)
            or util.root_pattern("*.swift")(filename)
        end,
        capabilities = {
          require("cmp_nvim_lsp").default_capabilities(),
        },
      },
    },
  },
}
