return {
  {
    'CopilotC-Nvim/CopilotChat.nvim',
    dependencies = {
      { 'zbirenbaum/copilot.lua' }, -- or
      { 'nvim-lua/plenary.nvim', branch = 'master' }, -- for curl, log and async functions
    },
    build = 'make tiktoken', -- Only on MacOS or Linux
    keys = {
      { '<leader>cc', '<cmd>CopilotChat<cr>', desc = 'CopilotChat' },
    },
    config = function()
      require('copilot').setup {
        enabled = false,
      }
      require('CopilotChat').setup {}
    end,
  },
}
