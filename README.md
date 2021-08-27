# look source for [nvim-cmp](https://github.com/hrsh7th/nvim-cmp)
This is look source for [hrsh7th/nvim-cmp](https://github.com/hrsh7th/nvim-cmp) and [Shougo/ddc.vim](https://github.com/Shougo/ddc.vim) inspired by [ujihisa/neco-look](https://github.com/ujihisa/neco-look).


## For nvim-cmp
```lua
local cmp = require('cmp')
local source = require('cmp_look').new()

-- limits the number of words in order to reduce UI blocking. If you want better
-- result just increase the number up.
source.word_limit = 4000

cmp.register_source('look', source)
cmp.setup({
  sources={{name='look'}}
})
```

## For ddc
```vim
call ddc#custom#patch_global('sources', ['look'])
```

## Alternatives
* [ujihisa/neco-look](https://github.com/ujihisa/neco-look)
* [matsui54/ddc-dictionary](https://github.com/matsui54/ddc-dictionary)
