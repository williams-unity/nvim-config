return {
  'stevearc/oil.nvim',
  ---@module 'oil'
  ---@type oil.SetupOpts
  opts = {},
  dependencies = { { 'echasnovski/mini.icons', opts = {} } },
  config = function()
    require('oil').setup {
      view_options = {
        show_hidden = true,
      },
    }
    vim.keymap.set('n', '<leader>-', '<cmd>Oil<cr>', { desc = 'Open parent dir' })
  end,
}
