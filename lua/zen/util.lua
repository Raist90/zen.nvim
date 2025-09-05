local M = {}

function M.is_empty_table(t)
  return type(t) == "table" and next(t) == nil
end

-- Clamp a value to a maximum, where the value can be an absolute number
---@param max number
---@param value number|fun():number A number > 1 is absolute, <= 1
function M.clamp_to_max(max, value)
  local ret = max
  if type(value) == "function" then
    ret = value()
  elseif value > 1 then
    ret = value
  else
    ret = ret * value
  end
  return math.min(ret, max)
end

function M.log(msg, hl)
  vim.api.nvim_echo({ { "ZenMode: ", hl }, { msg } }, true, {})
end

function M.error(msg)
  M.log(msg, "ErrorMsg")
end

return M
