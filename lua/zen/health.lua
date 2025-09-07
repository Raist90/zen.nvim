local get_user_opts = require("zen.config").get_user_opts
local default_opts = require("zen.config").default_opts
local is_empty_table = require("zen.util").is_empty_table

local M = {}

local function check_load()
  local ok = pcall(require, "zen")
  return ok
end

local function validate_opts(opts)
  local warns = {}
  local errs = {}

  if is_empty_table(opts) then
    table.insert(warns, "Options table is empty, using defaults")
  end

  for key, val in pairs(opts) do
    -- TODO: maybe use vim.validate for this kind of stuff?
    if key == "zindex" then
      if type(val) ~= "number" or val < 1 then
        table.insert(errs, "zindex should be a positive number")
      end
      if val == default_opts.zindex then
        table.insert(warns, "zindex is set to default value, you can safely omit it")
      end
    end

    if key == "window" then
      if type(val) ~= "table" then
        table.insert(errs, "window should be a table")
      else
        if type(val) == "table" then
          if is_empty_table(val) then
            table.insert(warns, "window options table is empty, using defaults")
          end
          if val.width ~= nil then
            local width = val.width
            if type(width) ~= "number" and type(width) ~= "function" then
              table.insert(errs, "window.width should be a number or a function")
            end
            -- TODO: add a allowed_range util to validate this kind of stuff
            if type(width) == "number" then
              if width < 1 then
                table.insert(errs, "window.width should be a positive number")
              end

              if width == default_opts.window.width then
                table.insert(warns, "window.width is set to default value, you can safely omit it")
              end
            end
            if type(width) == "function" then
              local ok, ret = pcall(width())
              if not ok or type(ret) ~= "number" or ret < 1 then
                table.insert(errs, "window.width function should return a positive number")
              end
            end
          end

          if val.height ~= nil then
            local height = val.height
            if type(height) ~= "number" and type(height) ~= "function" then
              table.insert(errs, "window.height should be a number or a function")
            end
            -- TODO: add a allowed_range util to validate this kind of stuff
            if type(height) == "number" then
              if height < 0 or height > 1 then
                table.insert(errs, "window.height should be a number between 0 and 1")
              end

              if height == default_opts.window.height then
                table.insert(warns, "window.height is set to default value, you can safely omit it")
              end
            end
            if type(height) == "function" then
              local ok, ret = pcall(height())
              if not ok or type(ret) ~= "number" or ret < 0 or ret > 1 then
                table.insert(errs, "window.height function should return a positive number")
              end
            end
          end
        end
      end
    end
  end

  return warns, errs
end

local function check_opts()
  local opts = get_user_opts
  return validate_opts(opts())
end

M.check = function()
  vim.health.start("Zen")

  if check_load() then
    vim.health.ok("Zen.nvim has been loaded successfully")

    local warns, errs = check_opts()
    for _, w in ipairs(warns) do
      vim.health.warn(w)
    end
    for _, e in ipairs(errs) do
      vim.health.error(e)
    end

    vim.health.ok("Zen.nvim setup looks good")
  else
    vim.health.error("There was an issue with Zen.nvim setup")
  end
end

return M
