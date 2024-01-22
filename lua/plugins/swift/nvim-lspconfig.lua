-- Configure lsp for support Swift language
-- Loads the Swift lsp from inside XCode
--

return {
  "neovim/nvim-lspconfig",
  event = { "BufReadPre", "BufNewFile" },
  dependencies = {
    "hrsh7th/cmp-nvim-lsp",
    { "antosha417/nvim-lsp-file-operations", config = true },
  },
  opts = {
    servers = {
      sourcekit = {
        cmd = {
          "/Applications/Xcode-15.2.0.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/sourcekit-lsp",
          "-Xswiftc",
          "-sdk",
          "-Xswiftc",
          "/Applications/Xcode-15.2.0.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator.sdk",
          "-Xswiftc",
          "-target",
          "-Xswiftc",
          "arm64-apple-ios17.2-simulator",
        },
        root_dir = function(filename, _)
          local util = require("lspconfig.util")

          return util.root_pattern("*.xcodeproj", "*.xcworkspace")(filename)
            or util.root_pattern("*.swift")(filename)
            or util.root_pattern("Package.swift")(filename)
            or util.find_git_ancestor(filename)
        end,
        capabilities = {
          require("cmp_nvim_lsp").default_capabilities(),
        },
      },
    },
  },
}
