local function find_all_projects(data, projects)
  projects = projects or {}
  for _, item in ipairs(data) do
    if item.Kind.Kind == 'msbuildFormat' then
      projects[item.Name] = item
    elseif item.Kind.Kind == 'folder' then
      find_all_projects(item.Kind.Data.Items, projects)
    end
  end
  return projects
end

local function workspace_load(client, bufnr, projects)
  local req = {
    TextDocuments = {},
  }
  for _, project in pairs(projects) do
    table.insert(req.TextDocuments, {
      Uri = 'file://' .. project.Name,
    })
  end

  client:request('fsharp/workspaceLoad', req, function(result, _)
    print(vim.inspect(result))
  end)
end
-- type WorkspacePeekRequest =
--   { Directory: string
--     Deep: int
--     ExcludedDirs: string array }
local function load_solution(bufnr, root_dir, solution_suffix)
  local req = {}
  req.Directory = root_dir
  req.Deep = 25
  req.ExcludedDirs = {}

  local clients = vim.lsp.get_clients { name = 'fsautocomplete', bufnr = bufnr }
  if #clients == 0 then
    print 'load_solution: got zero clients'
  end
  local client = clients[1]

  local pattern = '.*' .. solution_suffix .. '$'
  client:request('fsharp/workspacePeek', req, function(err, result, _)
    if err then
      print(vim.inspect(err))
      return
    end
    if not result then
      print 'load_solution: empty response'
      return
    end
    local resp = vim.json.decode(result.content)
    if not resp or not resp.Data or not resp.Data.Found then
      print 'load_solution: empty result'
      print(vim.inspect(resp))
      return
    end

    for _, found in pairs(resp.Data.Found) do
      local path = found.Data.Path
      if path and string.match(path, pattern) then
        local projects = find_all_projects(found.Data.Items)
        workspace_load(client, bufnr, projects)
      end
    end
  end)
end

vim.api.nvim_create_user_command('FSharpLoadWorkspace', function(args)
  return load_solution(vim.api.nvim_get_current_buf(), vim.fn.getcwd(), args.fargs[1])
end, {
  nargs = 1,
  complete = 'file',
})
