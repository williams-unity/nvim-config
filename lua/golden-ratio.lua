local M = {}
local golden_ratio = 1.618
local golden_ratio_squared = 1.27

local golden_ratio_width = function()
  local maxwidth = vim.o.columns
  return math.floor(maxwidth / golden_ratio)
end

local golden_ratio_minwidth = function()
  return math.floor(golden_ratio_width() / (3 * golden_ratio))
end

local golden_ratio_height = function()
  local maxheight = vim.o.lines
  return math.floor(maxheight / golden_ratio_squared)
end

function M.autoresize()
  local width = golden_ratio_width()
  local height = golden_ratio_height()

  -- save cmdheight to ensure it is not changed by nvim_win_set_height
  local cmdheight = vim.o.cmdheight

  -- local fixed = save_fixed_win_dims()

  vim.api.nvim_win_set_width(0, width)
  vim.api.nvim_win_set_height(0, height)

  -- restore_fixed_win_dims(fixed)

  vim.o.cmdheight = cmdheight
end

return M
