return {
  'akinsho/toggleterm.nvim',
  version = "*",
  config = function()
    require("toggleterm").setup {
      size = 15,
      open_mapping = [[<leader>t]], -- toggle with Ctrl+\
      direction = "float",          -- or 'float', 'vertical'
      shade_terminals = true,
      start_in_insert = true,
    }
  end,
}
