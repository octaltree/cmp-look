local cmp = require('cmp')
local luv = require('luv')
local debug = require('cmp.utils.debug')
local Job = require('plenary.job')

local M = {}

M.new = function()
  local self = setmetatable({}, { __index = M })
  self.word_limit = 4000
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
        if #res < self.word_limit then
          table.insert(res, { label = word })
        end
      end
    end,
    on_exit = function(j, return_val)
      processing = false
    end
  }):sync()

  callback({ items = res, isIncomplete = processing })
end

return M
