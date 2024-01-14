---@diagnostic disable: missing-fields
return {
  --
  -- Configure notify plugin
  --
  {
    "rcarriga/nvim-notify",
    name = "notify",
    config = function()
      require("notify").setup({
        background_colour = "#000000",
        fps = 60,
        render = "compact",
        stages = "fade",
        timeout = 3000,
      })
    end,
  },
}
