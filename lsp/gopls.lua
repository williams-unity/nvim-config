---@type vim.lsp.ClientConfig
return {
  cmd = { 'gopls' },
  root_markers = { 'go.mod' },
  filetypes = { 'go', 'go.mod', 'go.sum' },
  settings = {
    usePlaceholders = true,
    completeUnimported = true,
    hints = {
      assignVariableTypes = true,
      compositeLiteralFields = true,
      compositeLiteralTypes = true,
      constantValues = true,
      functionTypeParameters = true,
      parameterNames = true,
      rangeVariableTypes = true,
    },
  },
}
