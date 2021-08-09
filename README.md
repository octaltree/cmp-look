# look source for [nvim-cmp](https://github.com/hrsh7th/nvim-cmp)
This is look source for [hrsh7th/nvim-cmp](https://github.com/hrsh7th/nvim-cmp) inspired by [ujihisa/neco-look](https://github.com/ujihisa/neco-look).

```lua
local cmp = require('cmp')
cmp.register_source('look', require('cmp_look').new())
cmp.setup({
  sources={{name='look'}}
})
```
