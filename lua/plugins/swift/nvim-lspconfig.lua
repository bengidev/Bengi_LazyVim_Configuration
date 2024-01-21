-- Configure lsp for support Swift language
-- Loads the Swift lsp from inside XCode
--

return {
  "neovim/nvim-lspconfig",
  opts = {
    servers = {
      sourcekit = {
        cmd = {
          "/Applications/Xcode-15.2.0.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/sourcekit-lsp",
        },
        root_dir = function(filename, _)
          local util = require("lspconfig.util")

          return util.root_pattern("buildServer.json")(filename)
            or util.root_pattern("*.xcodeproj", "*.xcworkspace")(filename)
            or util.find_git_ancestor(filename)
            or util.root_pattern("Package.swift")(filename)
        end,
        capabilities = {
          require("cmp_nvim_lsp").default_capabilities(),
        },
      },
    },
  },
}
