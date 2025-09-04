local action = require("zen.action")
local config = require("zen.config")

local M = {}

M.setup = config.setup
M.toggle = action.toggle

return M
