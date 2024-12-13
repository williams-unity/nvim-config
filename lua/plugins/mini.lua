return { -- Collection of various small independent plugins/modules
  'echasnovski/mini.nvim',
  config = function()
    -- Better Around/Inside textobjects
    --
    -- Examples:
    --  - va)  - [V]isually select [A]round [)]paren
    --  - yinq - [Y]ank [I]nside [N]ext [Q]uote
    --  - ci'  - [C]hange [I]nside [']quote
    require('mini.ai').setup { n_lines = 500 }

    -- Add/delete/replace surroundings (brackets, quotes, etc.)
    --
    -- - saiw) - [S]urround [A]dd [I]nner [W]ord [)]Paren
    -- - sd'   - [S]urround [D]elete [']quotes
    -- - sr)'  - [S]urround [R]eplace [)] [']
    require('mini.surround').setup()
    require('mini.jump2d').setup()

    vim.keymap.set({ 'n', 'v' }, '<leader>jw', function()
      print 'Press key: '
      local c = vim.fn.getcharstr()
      print ''
      local lower = c:lower()
      local upper = c:upper()
      local cclass = '[' .. lower .. upper .. ']'

      local startline = MiniJump2d.gen_pattern_spotter('^' .. cclass, 'start')
      local inline = MiniJump2d.gen_pattern_spotter('[%s%p]()' .. cclass .. '[^%s%p]*', 'none')
      MiniJump2d.start {
        spotter = function(linenum, args)
          local a = startline(linenum, args)
          local b = inline(linenum, args)
          if a == nil then
            return b
          end
          if b == nil then
            return a
          end
          for _, v in pairs(a) do
            table.insert(b, v)
          end
          return b
        end,
        allowed_lines = { blank = false },
      }
    end, {})

    -- Simple and easy statusline.
    --  You could remove this setup call if you don't like it,
    --  and try some other statusline plugin
    local statusline = require 'mini.statusline'
    -- set use_icons to true if you have a Nerd Font
    statusline.setup { use_icons = vim.g.have_nerd_font }

    -- You can configure sections in the statusline by overriding their
    -- default behavior. For example, here we set the section for
    -- cursor location to LINE:COLUMN
    ---@diagnostic disable-next-line: duplicate-set-field
    statusline.section_location = function()
      return '%2l:%-2v'
    end

    -- ... and there is more!
    --  Check out: https://github.com/echasnovski/mini.nvim
  end,
}
