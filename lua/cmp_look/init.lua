local cmp = require('cmp')
local luv = require('luv')
local debug = require('cmp.utils.debug')
local Job = require('plenary.job')

local M = {}

M.new = function()
  local self = setmetatable({}, { __index = M })
  return self
end

M.get_keyword_pattern = function()
  return [[\w\{2,}]]
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

local has = function(target, arr)
  for _, v in ipairs(arr) do
    if target == v then
      return true
    end
  end
  return false
end

M.complete = function(self, request, callback)
  local q = string.sub(request.context.cursor_before_line, request.offset)
  local res = {}
  local processing = true

  Job:new({
    command = 'look',
    args = {'--', q},
    on_stdout = function(err, chunk)
      local words = split(chunk)
      for _, word in ipairs(words) do
        table.insert(res, { label = word })
      end
    end,
    on_exit = function(j, return_val)
      processing = false
    end
  }):sync()

  callback({ items = res, isIncomplete = processing })
end

return M
