local cmp = require('cmp')
local luv = require('luv')
local debug = require('cmp.utils.debug')

local M = {}

M.new = function()
  local self = setmetatable({}, { __index = M })
  return self
end

M.get_keyword_pattern = function()
  return [[\w\+]]
end

local split = function(str)
  local sep = '%s'
  local ret = {}
  for s in string.gmatch(str, '([^'..sep..']+)') do
    if s ~= '' then
      table.insert(ret, s)
    end
  end
  return ret
end

local candidates = function(words)
  local ret = {}
  for _, w in ipairs(words) do
    table.insert(ret, {label=w})
  end
  return ret
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
      vim.schedule_wrap(callback)(candidates(words))
    end)
    if handle == nil then
      debug.log(string.format("start `%s` failed: %s", cmd, pid))
    end
    luv.read_start(stdioe[2], function(err, chunk)
      assert(not err, err)
      if chunk then
        buf = buf .. chunk
      end
      local ws = split(buf)
      for i, w in ipairs(ws) do
        if i ~= #ws then
          table.insert(words, w)
        else
          buf = w
        end
      end
    end)
  end
end

return M
