return {
  'stevearc/oil.nvim',
  ---@module 'oil'
  ---@type oil.SetupOpts
  opts = {},
  dependencies = { { 'echasnovski/mini.icons', opts = {} } },
  config = function()
    require('oil').setup()
    vim.keymap.set('n', '<leader>-', '<cmd>Oil<cr>', { desc = 'Open parent dir' })
  end,
}
