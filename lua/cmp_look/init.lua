local cmp = require('cmp')
local luv = require('luv')
local debug = require('cmp.utils.debug')
local config = require('cmp.config')

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

local function map(f, xs)
  local ret = {}
  for _, x in ipairs(xs) do
    table.insert(ret, f(x))
  end
  return ret
end

local convert_case, isUpper
do
  local function conv(spans, word)
    local ret = ''
    local i = 1
    local f = function(v, s)
      if v < 0 then
        return s:lower()
      elseif v > 0 then
        return s:upper()
      else
        return s
      end
    end
    for _, s in ipairs(spans) do
      target = word:sub(i, i + s.n - 1)
      ret = ret .. f(s.v, target)
      i = i + s.n
    end
    ret = ret .. string.sub(word, i)
    return ret;
  end

  local function isLower(c)
    return c:lower() == c
  end

  function isUpper(c)
    return c:upper() == c
  end

  local function unique(xs)
    local pool = {}
    local ret = {}
    for _, v in ipairs(xs) do
      if not pool[v] then
        table.insert(ret, v)
        pool[v] = true
      end
    end
    return ret
  end

  function convert_case(query, words)
    local flg = {}
    for c in query:gmatch"." do
      if isLower(c) then
        table.insert(flg, -1)
      elseif isUpper(c) then
        table.insert(flg, 1)
      else
        table.insert(flg, 0)
      end
    end
    local spans = {}
    for _, c in ipairs(flg) do
      if #spans == 0 then
        table.insert(spans, {v = c, n = 1})
      else
        local last = spans[#spans]
        if last.v == c then
          last.n = last.n + 1
        else
          table.insert(spans, {v = c, n = 1})
        end
      end
    end
    return unique(map(function(w) return conv(spans, w) end, words))
  end
end

local function construct_args(q, option, len)
  local args = {}
  -- https://github.com/util-linux/util-linux/blob/90eeee21c69aa805709376ad8282e68b5bd65c34/misc-utils/look.c#L137-L149
  local dflag = not option.dict or option.dflag
  if option.dict then
    if option.dflag then
      table.insert(args, '-d')
    end
    if option.fflag then
      table.insert(args, '-f')
    end
    for _, x in ipairs({'--', q, option.dict}) do
      table.insert(args, x)
    end
  else
    for _, x in ipairs({'--', q}) do
      table.insert(args, x)
    end
  end
  if dflag then
    local alph = string.gsub(q, '%W', '')
    if string.len(alph) < len then
      return nil
    end
  end
  return args
end

-- Generic source options should be easily accessible from all sources
local function get_keyword_length(request)
  if request.keyword_length then
    return request.keyword_length
  end
  return config.get().completion.keyword_length or 1
end

M.complete = function(self, request, callback)
  local q = string.sub(request.context.cursor_before_line, request.offset)
  local args = construct_args(q, request.option, get_keyword_length(request))
  if not args then
    callback({})
  end
  local should_convert_case = request.option.convert_case or false
  local should_convert_loud = (request.option.loud or false) and isUpper(q)
  local stdioe = pipes()
  local handle, pid
  local buf = ''
  local words = {}
  do
    local spawn_params = {
      args = args,
      stdio = stdioe
    }
    handle, pid = luv.spawn('look', spawn_params, function(code, signal)
      stdioe[1]:close()
      stdioe[2]:close()
      stdioe[3]:close()
      handle:close()
      local xs = words
      if should_convert_case then xs = convert_case(q, xs) end
      if should_convert_loud then
        xs = map(function(w) return w:upper() end, xs)
      end
      callback(result(xs))
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
