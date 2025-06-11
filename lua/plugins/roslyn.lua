return {
  'seblyng/roslyn.nvim',
  ft = 'cs',
  ---@module 'roslyn.config'
  ---@type RoslynNvimConfig
  opts = {
    exe = {
      'dotnet',
      vim.fs.joinpath(
        vim.fn.expand '~',
        'repos',
        'roslyn',
        'artifacts/bin/Microsoft.CodeAnalysis.LanguageServer/Release/net9.0/Microsoft.CodeAnalysis.LanguageServer.dll'
      ),
    },
    broad_search = true,
    lock_target = true,
    choose_target = function(targets)
      require 'telescope'

      local selected = nil
      vim.ui.select(targets, { 'Select a solution.' }, function(item, _idx)
        selected = item
      end)
      return selected
    end,
  },
}
