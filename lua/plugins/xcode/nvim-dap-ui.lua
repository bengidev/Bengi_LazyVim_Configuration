return {
  "rcarriga/nvim-dap-ui",
  dependencies = { "mfussenegger/nvim-dap" },
  lazy = true,
  config = function()
    require("dapui").setup({
      controls = {
        element = "repl",
        enabled = true,
        icons = {
          disconnect = "󱐤",
          run_last = "󰑙",
          terminate = "",
          pause = "󰏤",
          play = "",
          step_into = "󰆹",
          step_out = "󰆸",
          step_over = "󰆷",
          step_back = "󰓕",
        },
      },
      floating = {
        border = "single",
        mappings = {
          close = { "q", "<Esc>" },
        },
      },
      icons = { collapsed = "", expanded = "", current_frame = "" },
      layouts = {
        {
          elements = {
            { id = "stacks", size = 0.25 },
            { id = "scopes", size = 0.25 },
            { id = "breakpoints", size = 0.25 },
            { id = "watches", size = 0.25 },
          },
          position = "left",
          size = 60,
        },
        {
          elements = {
            { id = "repl", size = 1.0 },
          },
          position = "bottom",
          size = 10,
        },
      },
    })

    local dap, dapui = require("dap"), require("dapui")

    dap.listeners.after.event_initialized["dapui_config"] = function()
      dapui.open()
    end
    dap.listeners.before.event_terminated["dapui_config"] = function()
      dapui.close()
    end
    dap.listeners.before.event_exited["dapui_config"] = function()
      dapui.close()
    end
  end,
}
