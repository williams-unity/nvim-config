---@type vim.lsp.Config
return {
  cmd = { 'tsgo', '--lsp', '--stdio' },
  filetypes = {
    'javascript',
    'javascriptreact',
    'javascript.jsx',
    'typescript',
    'typescriptreact',
    'typescript.tsx',
  },
  root_markers = { 'tsconfig.base.json', 'tsconfig.json', 'jsconfig.json', 'package.json', '.git' },
  log_level = vim.lsp.protocol.MessageType.Debug,
}
