local M = {}

function M.is_empty_table(t)
  return type(t) == "table" and next(t) == nil
end

-- Calculate a ratio of a maximum value.
---@param max number
---@param value number|fun():number A number > 1 is absolute, <= 1
function M.ratio(max, value)
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

return M
