local state = {
  win_nr = -1,
  buf_nr = -1,
  last_command = nil,
  last_command_opts = nil,
  last_command_obj = nil,
}

local opts = {
  exec_in_bash = true,
}

local attach_terminal_below = function(buf_nr)
  local cur_pos = vim.api.nvim_win_get_position(0)
  local lowest_win = 0
  local lowest_col = 0
  for _, win in pairs(vim.api.nvim_list_wins()) do
    local pos = vim.api.nvim_win_get_position(win)
    if cur_pos[2] == pos[2] and pos[1] > lowest_col then
      lowest_win = win
      lowest_col = pos[2]
    end
  end
  state.win_nr = vim.api.nvim_open_win(buf_nr, true, {
    split = 'below',
    height = math.floor(vim.o.lines * 0.15),
    win = lowest_win,
  })
  -- if vim.bo[buf_nr].buftype ~= 'terminal' then
  --   vim.cmd.terminal()
  -- end
end

local attach_terminal_right = function(buf_nr)
  local rightest_win = 0
  local rightest_col = 0
  for _, win in pairs(vim.api.nvim_list_wins()) do
    if vim.api.nvim_win_get_config(win).relative ~= '' then
      goto continue
    end

    local pos = vim.api.nvim_win_get_position(win)
    if pos[2] > rightest_col then
      rightest_win = win
      rightest_col = pos[2]
    end
    ::continue::
  end
  state.win_nr = vim.api.nvim_open_win(buf_nr, true, {
    split = 'right',
    height = math.floor(vim.o.columns * 0.4),
    win = rightest_win,
  })
end

local attach_terminal = attach_terminal_right

local create_split = function()
  if not vim.api.nvim_buf_is_valid(state.buf_nr) then
    state.buf_nr = vim.api.nvim_create_buf(true, false)
    vim.api.nvim_buf_set_name(state.buf_nr, '*Command*')
  end

  if not vim.api.nvim_win_is_valid(state.win_nr) or vim.api.nvim_win_get_buf(state.win_nr) ~= state.buf_nr then
    attach_terminal(state.buf_nr)
  end
end

local toggle_split = function()
  if vim.api.nvim_win_is_valid(state.win_nr) then
    vim.api.nvim_win_hide(state.win_nr)
    return false
  else
    local cur_win = vim.api.nvim_get_current_win()
    create_split()
    vim.api.nvim_set_current_win(cur_win)
    return true
  end
end

local kill_current_command = function()
  if state.last_command_obj ~= nil then
    state.last_command_obj.kill(state.last_command_obj, 9)
  end
end

local term_command = function(cur_win, win, _, cmd, args)
  kill_current_command()
  args = args or {}
  local buf = vim.api.nvim_win_get_buf(win)
  vim.api.nvim_set_current_win(cur_win)

  local chan = vim.api.nvim_open_term(buf, {})
  local line_count = vim.api.nvim_buf_line_count(buf)
  vim.api.nvim_win_set_cursor(win, { line_count, 0 })
  local write_to_term = function(text)
    for _, data in ipairs(text) do
      vim.api.nvim_chan_send(chan, data)
    end
  end
  write_to_term { 'workdir=', args.cwd or vim.uv.cwd(), '; ', 'cmd=', table.concat(cmd, ' '), '\r\n\r\n' }

  local handle_output = function(_, data)
    if not data or #data == 0 then
      return
    end
    write_to_term { data }
  end
  handle_output = vim.schedule_wrap(handle_output)
  local obj = vim.system(cmd, {
    cwd = args.cwd,
    stdout = handle_output,
    stderr = handle_output,
    text = true,
  }, function(sc)
    vim.schedule(function()
      write_to_term { '\n', '[Process exited ', tostring(sc.code), ']' }
      state.last_command_obj = nil
    end)
  end)

  state.last_command = cmd
  state.last_command_opts = args
  state.last_command_obj = obj
end

local run_last_command = function()
  if not vim.api.nvim_buf_is_valid(state.buf_nr) then
    return
  end
  if not state.last_command then
    return
  end
  local cur_win = vim.api.nvim_get_current_win()
  if not vim.api.nvim_win_is_valid(state.win_nr) or vim.api.nvim_win_get_buf(state.win_nr) ~= state.buf_nr then
    attach_terminal(state.buf_nr)
  end

  -- send_keys_and_back(cur_win, state.win_nr, state.buf_nr, '\x1b[A\n')
  term_command(cur_win, state.win_nr, state.buf_nr, state.last_command, state.last_command_opts)
end

local handle_command_args = function(args)
  if not opts.exec_in_bash then
    local expanded_args = {}
    for _, arg in ipairs(args.fargs) do
      table.insert(expanded_args, vim.fn.expand(arg))
    end
    return expanded_args
  end

  args = vim.fn.expand(args.args)
  return { 'bash', '-c', args }
end

vim.api.nvim_create_user_command('TT', function(args)
  local cur_win = vim.api.nvim_get_current_win()
  local expanded_args = handle_command_args(args)
  create_split()
  -- send_keys_and_back(cur_win, state.win_nr, state.buf_nr, args.args .. '\n')
  term_command(cur_win, state.win_nr, state.buf_nr, expanded_args, {})
end, {
  nargs = '*',
  complete = 'shellcmd',
})

local trim_wd = function(wd)
  wd = string.gsub(wd, '^oil://', '')
  return wd
end

vim.api.nvim_create_user_command('TD', function(args)
  local cwd = trim_wd(vim.fn.expand '%:h')
  local expanded_args = handle_command_args(args)
  local cur_win = vim.api.nvim_get_current_win()
  create_split()
  -- send_keys_and_back(cur_win, state.win_nr, state.buf_nr, args.args .. '\n', { cwd = cwd })
  term_command(cur_win, state.win_nr, state.buf_nr, expanded_args, { cwd = cwd })
end, {
  nargs = '*',
  complete = 'shellcmd',
})

vim.keymap.set({ 'n' }, '<leader>tt', ':TT ', { desc = 'Run [T]erminal Command' })
vim.keymap.set({ 'n' }, '<leader>td', ':TD ', { desc = 'Run [T]erminal Command in File [D]ir' })
vim.keymap.set({ 'n' }, '<leader>tr', run_last_command, { desc = '[T]erminal [R]epeat Command' })
vim.keymap.set({ 'n' }, '<leader>th', toggle_split, { desc = 'Toggle [H]ide [T]erminal Window' })
