local cmp = require('cmp')
local luv = require('luv')
local debug = require('cmp.utils.debug')

local M = {}

M.new = function()
  local self = setmetatable({}, { __index = M })
  return self
end

local trim = function(str)
  return string.gsub(str, '^%s*(.-)%s*$', '%1')
end

local line = function(str)
  local s, e, cap = string.find(str, '\n')
  if not s then
    return nil, str
  end
  local l = string.sub(str, 1, s - 1)
  local rest = string.sub(str, e + 1)
  return l, rest
end

local result = function(words)
  local items = {}
  for _, w in ipairs(words) do
    table.insert(items, {label=w})
  end
  return {items=items, isIncomplete=true}
end

local pipes = function()
  local stdin = luv.new_pipe(false)
  local stdout = luv.new_pipe(false)
  local stderr = luv.new_pipe(false)
  return {stdin, stdout, stderr}
end

M.complete = function(self, request, callback)
  local q = string.sub(request.context.cursor_before_line, request.offset)
  local stdioe = pipes()
  local handle, pid
  local buf = ''
  local words = {}
  do
    local spawn_params = {
      args = {'--', q},
      stdio = stdioe
    }
    handle, pid = luv.spawn('look', spawn_params, function(code, signal)
      stdioe[1]:close()
      stdioe[2]:close()
      stdioe[3]:close()
      handle:close()
      vim.schedule_wrap(callback)(result(words))
    end)
    if handle == nil then
      debug.log(string.format("start `%s` failed: %s", cmd, pid))
    end
    luv.read_start(stdioe[2], function(err, chunk)
      assert(not err, err)
      if chunk then
        buf = buf .. chunk
      end
      while true do
        local l, rest = line(buf)
        if l == nil then
          break
        end
        buf = rest
        local w = trim(l)
        if w ~= '' then
          table.insert(words, w)
        end
      end
    end)
  end
end

return M
