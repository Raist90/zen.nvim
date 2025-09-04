local M = {}

M.bg_win = nil
M.bg_buf = nil
M.parent = nil
M.win = nil
M.opts = nil

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

function M.setup(opts)
  M.opts = vim.tbl_deep_extend("force", {}, M.default_opts, opts or {})
end

function M.round(num)
  return math.floor(num + 0.5)
end

function M.resolve(max, value)
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

function M.height()
  local height = vim.o.lines - vim.o.cmdheight
  return (vim.o.laststatus == 3) and height - 1 or height
end

function M.layout(opts)
  local width = M.resolve(vim.o.columns, opts.window.width)
  local height = M.resolve(M.height(), opts.window.height)

  return {
    width = M.round(width),
    height = M.round(height),
    col = M.round((vim.o.columns - width) / 2),
    row = M.round((M.height() - height) / 2),
  }
end

function M.fix_hl(win, normal)
  local cwin = vim.api.nvim_get_current_win()
  if cwin ~= win then
    vim.api.nvim_set_current_win(win)
  end
  normal = normal or "Normal"
  vim.cmd("setlocal winhl=NormalFloat:" .. normal .. ",FloatBorder:ZenBorder,EndOfBuffer:" .. normal)
  vim.cmd("setlocal winblend=0")
  vim.cmd([[setlocal fcs=eob:\ ,fold:\ ,vert:\]])
  -- vim.api.nvim_win_set_option(win, "winhighlight", "NormalFloat:" .. normal)
  -- vim.api.nvim_win_set_option(win, "fcs", "eob: ")
  vim.api.nvim_set_current_win(cwin)
end

function M.is_open()
  return M.win and vim.api.nvim_win_is_valid(M.win)
end

function M.on_buf_win_enter()
  if vim.api.nvim_get_current_win() == M.win then
    M.fix_hl(M.win)
  end
end

function M.fix_layout(win_resized)
  if M.is_open() then
    if win_resized then
      local l = M.layout(M.opts)
      vim.api.nvim_win_set_config(M.win, { width = l.width, height = l.height })
      vim.api.nvim_win_set_config(M.bg_win, { width = vim.o.columns, height = M.height() })
    end
    local height = vim.api.nvim_win_get_height(M.win)
    local width = vim.api.nvim_win_get_width(M.win)
    local col = M.round((vim.o.columns - width) / 2)
    local row = M.round((M.height() - height) / 2)
    local cfg = vim.api.nvim_win_get_config(M.win)
    -- HACK: col is an array?
    local wcol = type(cfg.col) == "number" and cfg.col or cfg.col[false]
    local wrow = type(cfg.row) == "number" and cfg.row or cfg.row[false]
    if wrow ~= row or wcol ~= col then
      vim.api.nvim_win_set_config(M.win, { col = col, row = row, relative = "editor" })
    end
  end
end

function M.close()
  local closed_buf = vim.api.nvim_get_current_buf()

  pcall(vim.api.nvim_del_augroup_by_name, "Zen")

  -- Change the parent window's cursor position to match
  -- the cursor position in the zen-mode window.
  if M.parent and M.win then
    -- Ensure that the parent window has the same buffer
    -- as the zen-mode window.
    if vim.api.nvim_win_get_buf(M.parent) == vim.api.nvim_win_get_buf(M.win) then
      -- Then, update the parent window's cursor position.
      vim.api.nvim_win_set_cursor(M.parent, vim.api.nvim_win_get_cursor(M.win))
    end
  end

  if M.win and vim.api.nvim_win_is_valid(M.win) then
    vim.api.nvim_win_close(M.win, true)
    M.win = nil
  end
  if M.bg_win and vim.api.nvim_win_is_valid(M.bg_win) then
    vim.api.nvim_win_close(M.bg_win, true)
    M.bg_win = nil
  end
  if M.bg_buf and vim.api.nvim_buf_is_valid(M.bg_buf) then
    vim.api.nvim_buf_delete(M.bg_buf, { force = true })
    M.bg_buf = nil
  end
  if M.opts then
    M.opts = nil
    if M.parent and vim.api.nvim_win_is_valid(M.parent) then
      vim.api.nvim_set_current_win(M.parent)
    end
  end

  local curr_buf = vim.api.nvim_get_current_buf()
  if closed_buf == curr_buf then
    return
  end
  vim.api.nvim_set_current_buf(closed_buf)
end

function M.open(opts)
  if not M.is_open() then
    -- close any possible remnants from a previous session
    -- shouldn't happen, but just in case
    M.close()
    M.create(opts or M.opts)
  end
end

function M.toggle()
  if M.is_open() then
    M.close()
  else
    M.open(M.opts)
  end
end

---@param opts ZenOpts
function M.create(opts)
  if opts == nil then
    opts = M.default_opts
  end

  M.parent = vim.api.nvim_get_current_win()
  M.bg_buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_set_option_value("filetype", "zenmode-bg", { buf = M.bg_buf })
  local ok
  ok, M.bg_win = pcall(vim.api.nvim_open_win, M.bg_buf, false, {
    relative = "editor",
    width = vim.o.columns,
    height = M.height(),
    focusable = false,
    row = 0,
    col = 0,
    style = "minimal",
    zindex = opts.zindex - 10,
  })
  if not ok then
    M.error("could not open floating window. You need a Neovim build that supports zindex (May 15 2021 or newer)")
    M.bg_win = nil
    return
  end
  M.fix_hl(M.bg_win, "ZenBg")

  local win_opts = vim.tbl_extend("keep", {
    relative = "editor",
    zindex = opts.zindex,
  }, M.layout(opts))

  local buf = vim.api.nvim_get_current_buf()
  M.win = vim.api.nvim_open_win(buf, true, win_opts)
  vim.cmd([[norm! zz]])
  M.fix_hl(M.win)

  M.fix_layout()

  require("zen.autocmds").setup(M.win)
end

function M.is_float(win)
  local opts = vim.api.nvim_win_get_config(win)
  return opts and opts.relative and opts.relative ~= ""
end

function M.on_win_enter()
  local win = vim.api.nvim_get_current_win()
  if win ~= M.win and not M.is_float(win) then
    -- HACK: when returning from a float window, vim initially enters the parent window.
    -- give 10ms to get back to the zen window before closing
    vim.defer_fn(function()
      if vim.api.nvim_get_current_win() ~= M.win then
        M.close()
      end
    end, 10)
  end
end

return M
