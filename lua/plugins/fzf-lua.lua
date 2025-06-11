return {
  'ibhagwan/fzf-lua',
  -- -- optional for icon support
  -- dependencies = { 'nvim-tree/nvim-web-devicons' },
  config = function()
    require('fzf-lua').setup { 'ivy' }

    -- See `:help telescope.fzflua`
    local fzflua = require 'fzf-lua'
    local actions = require 'fzf-lua.actions'
    fzflua.register_ui_select()
    vim.keymap.set('n', '<leader>sh', fzflua.help_tags, { desc = '[S]earch [H]elp' })
    vim.keymap.set('n', '<leader>sk', fzflua.keymaps, { desc = '[S]earch [K]eymaps' })
    vim.keymap.set('n', '<leader>sf', fzflua.files, { desc = '[S]earch [F]iles' })
    vim.keymap.set('n', '<leader>ss', fzflua.builtin, { desc = '[S]earch [S]elect' })
    vim.keymap.set('n', '<leader>sw', fzflua.grep_cword, { desc = '[S]earch current [W]ord' })
    vim.keymap.set('n', '<leader>sg', function()
      fzflua.live_grep {
        actions = {
          ['ctrl-g'] = { actions.grep_lgrep },
          ['ctrl-h'] = { actions.toggle_hidden },
          ['ctrl-q'] = { fn = actions.file_sel_to_qf, prefix = 'select-all' },
        },
      }
    end, { desc = '[S]earch by [G]rep' })
    vim.keymap.set('n', '<leader>sd', fzflua.diagnostics_document, { desc = '[S]earch [D]iagnostics' })
    vim.keymap.set('n', '<leader>sr', fzflua.resume, { desc = '[S]earch [R]esume' })
    -- vim.keymap.set('n', '<leader>s.', fzflua.oldfiles, { desc = '[S]earch Recent Files ("." for repeat)' })
    vim.keymap.set('n', '<leader><leader>', fzflua.buffers, { desc = '[ ] Find existing buffers' })

    vim.keymap.set('n', '<leader>/', function()
      fzflua.blines { debug = false }
    end, { desc = '[/] Fuzzily search in current buffer' })

    -- Shortcut for searching your Neovim configuration files
    vim.keymap.set('n', '<leader>sn', function()
      fzflua.files { cwd = vim.fn.stdpath 'config' }
    end, { desc = '[S]earch [N]eovim files' })

    vim.keymap.set('n', '<leader>ff', function()
      fzflua.files { cwd = vim.fn.expand '%:h' }
    end)
  end,
}
