local state = {
  win_nr = -1,
  buf_nr = -1,
  last_command = nil,
}

local attach_terminal = function(buf_nr)
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

local create_split = function()
  if not vim.api.nvim_buf_is_valid(state.buf_nr) then
    state.buf_nr = vim.api.nvim_create_buf(false, true)
  end

  if not vim.api.nvim_win_is_valid(state.win_nr) then
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

local toggle_split_insert = function()
  if toggle_split() then
    vim.cmd.startinsert()
  end
end

local send_keys_and_back = function(cur_win, win, buf, cmd, args)
  args = args or {}
  local chan = vim.bo[state.buf_nr].channel
  local line_count = vim.api.nvim_buf_line_count(buf)
  vim.api.nvim_win_set_cursor(win, { line_count, 0 })
  vim.api.nvim_chan_send(chan, cmd)
  vim.api.nvim_set_current_win(cur_win)
end

local term_command = function(cur_win, win, _, cmd, args)
  args = args or {}
  if args.cwd then
    table.insert(cmd, 1, '&&')
    table.insert(cmd, 1, args.cwd)
    table.insert(cmd, 1, 'cd')
  end
  vim.api.nvim_set_current_win(win)
  vim.api.nvim_cmd({ cmd = 'terminal', args = cmd }, {})
  local buf = vim.api.nvim_win_get_buf(win)
  local line_count = vim.api.nvim_buf_line_count(buf)
  vim.api.nvim_win_set_cursor(win, { line_count, 0 })
  vim.api.nvim_set_current_win(cur_win)
  state.last_command = cmd
end

local run_last_command = function()
  if not vim.api.nvim_buf_is_valid(state.buf_nr) then
    return
  end
  if not state.last_command then
    return
  end
  local cur_win = vim.api.nvim_get_current_win()
  if not vim.api.nvim_win_is_valid(state.win_nr) then
    attach_terminal(state.buf_nr)
  end

  -- send_keys_and_back(cur_win, state.win_nr, state.buf_nr, '\x1b[A\n')
  term_command(cur_win, state.win_nr, state.buf_nr, state.last_command, {})
end

vim.api.nvim_create_user_command('TT', function(args)
  local cur_win = vim.api.nvim_get_current_win()
  create_split()
  -- send_keys_and_back(cur_win, state.win_nr, state.buf_nr, args.args .. '\n')
  term_command(cur_win, state.win_nr, state.buf_nr, args.fargs, {})
end, {
  nargs = '?',
  complete = 'shellcmd',
})

vim.api.nvim_create_user_command('TD', function(args)
  local cwd = vim.fn.expand '%:h'
  local cur_win = vim.api.nvim_get_current_win()
  create_split()
  -- send_keys_and_back(cur_win, state.win_nr, state.buf_nr, args.args .. '\n', { cwd = cwd })
  term_command(cur_win, state.win_nr, state.buf_nr, args.fargs, { cwd = cwd })
end, {
  nargs = '?',
  complete = 'shellcmd',
})

vim.keymap.set({ 'n' }, '<leader>tt', ':TT ', { desc = 'Run [T]erminal Command' })
vim.keymap.set({ 'n' }, '<leader>td', ':TD ', { desc = 'Run [T]erminal Command in File [D]ir' })
vim.keymap.set({ 'n' }, '<leader>tr', run_last_command, { desc = '[T]erminal [R]epeat Command' })
vim.keymap.set({ 'n' }, '<leader>th', toggle_split, { desc = 'Toggle [H]ide [T]erminal Window' })
