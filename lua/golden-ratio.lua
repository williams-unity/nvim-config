local M = {}
local golden_ratio = 1.618

local golden_ratio_width = function()
  local maxwidth = vim.o.columns
  return math.floor(maxwidth / golden_ratio)
end

local golden_ratio_minwidth = function()
  return math.floor(golden_ratio_width() / (3 * golden_ratio))
end

local golden_ratio_height = function()
  local maxheight = vim.o.lines
  return math.floor(maxheight / golden_ratio)
end

local golden_ratio_minheight = function()
  return math.floor(golden_ratio_height() / (3 * golden_ratio))
end

local function save_fixed_win_dims()
  local fixed_dims = {}

  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    if vim.api.nvim_win_get_config(win).zindex == nil then
      local buf = vim.api.nvim_win_get_buf(win)
      if vim.w[win].focus_disable or vim.b[buf].focus_disable then
        fixed_dims[win] = {
          width = vim.api.nvim_win_get_width(win),
          height = vim.api.nvim_win_get_height(win),
        }
      end
    end
  end

  return fixed_dims
end

local function restore_fixed_win_dims(fixed_dims)
  for win, dims in pairs(fixed_dims) do
    if vim.api.nvim_win_is_valid(win) then
      vim.api.nvim_win_set_width(win, dims.width)
      vim.api.nvim_win_set_height(win, dims.height)
    end
  end
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
