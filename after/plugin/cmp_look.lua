local ok, cmp = pcall(require, 'cmp')
if ok then cmp.register_source('look', require('cmp_look').new()) end
