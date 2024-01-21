local cmp_nvim_lsp = require("cmp_nvim_lsp")
local opts = { noremap = true, silent = true }
local util = require("lspconfig.util")

return {
  "neovim/nvim-lspconfig",
  opts = {
    servers = {
      sourcekit = {
        cmd = {
          "/Applications/Xcode-15.2.0.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/sourcekit-lsp",
        },
        root_dir = function(filename, _)
          return util.root_pattern("buildServer.json")(filename)
            or util.root_pattern("*.xcodeproj", "*.xcworkspace")(filename)
            or util.find_git_ancestor(filename)
            or util.root_pattern("Package.swift")(filename)
        end,
        capabilities = {
          cmp_nvim_lsp.default_capabilities(),
        },
        on_attach = function(_, bufnr)
          opts.buffer = bufnr

          opts.desc = "Show line diagnostics"
          vim.keymap.set("n", "<leader>d", vim.diagnostic.open_float, opts)

          opts.desc = "Show documentation for what is under cursor"
          vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
        end,
      },
    },
  },
}
