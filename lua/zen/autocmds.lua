local M = {}

-- TODO: listen for WinNew and BufEnter. When a new window, or bufenter in a new window, close zen mode
-- unless it's in a float
-- TODO: when the cursor leaves the window, we close zen mode, or prevent leaving the window
function M.setup(win)
  local group = vim.api.nvim_create_augroup("Zen", { clear = true })

  vim.api.nvim_create_autocmd("WinClosed", {
    pattern = tostring(win),
    group = group,
    callback = function() require("zen").close() end,
    once = true,
    nested = true,
  })

  vim.api.nvim_create_autocmd("WinEnter", {
    group = group,
    callback = function() require("zen").on_win_enter() end,
  })

  vim.api.nvim_create_autocmd({ "CursorMoved", "CursorHold" }, {
    group = group,
    callback = function() require("zen").fix_layout() end,
  })

  vim.api.nvim_create_autocmd("VimResized", {
    group = group,
    callback = function() require("zen").fix_layout(true) end,
  })

  vim.api.nvim_create_autocmd("BufWinEnter", {
    group = group,
    callback = function() require("zen").on_buf_win_enter() end,
  })
end

return M
