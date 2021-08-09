# look source for [nvim-cmp](https://github.com/hrsh7th/nvim-cmp)
This is look source for [hrsh7th/nvim-cmp](https://github.com/hrsh7th/nvim-cmp) and [Shougo/ddc..vim](https://github.com/hrsh7th/nvim-cmp) inspired by [ujihisa/neco-look](https://github.com/ujihisa/neco-look).


## For nvim-cmp
```lua
local cmp = require('cmp')
cmp.register_source('look', require('cmp_look').new())
cmp.setup({
  sources={{name='look'}}
})
```

## For ddc
```vim
call ddc#register_source({
      \ 'name': 'look',
      \ 'path': 'https://raw.githubusercontent.com/octaltree/ddc-look/main/denops/ddc/sources/look.vim'
      \ })
```
