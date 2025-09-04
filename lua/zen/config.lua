local M = {}

---@class ZenWindowOpt
---@field width number|fun():number
---@field height number|fun():number

---@class ZenOpts
---@field window ZenWindowOpt
---@field zindex number

---@type ZenOpts
M.default_opts = {
  window = {
    width = 120,
    height = 1,
  },
  zindex = 40,
}

---@param opts ZenOpts
function M.setup(opts)
  M.opts = vim.tbl_deep_extend("force", {}, M.default_opts, opts)
end

function M.get_opts()
  return M.opts or M.default_opts
end

return M
