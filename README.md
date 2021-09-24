# look source for [nvim-cmp](https://github.com/hrsh7th/nvim-cmp)
This is look source for [hrsh7th/nvim-cmp](https://github.com/hrsh7th/nvim-cmp) and [Shougo/ddc.vim](https://github.com/Shougo/ddc.vim) inspired by [ujihisa/neco-look](https://github.com/ujihisa/neco-look).

![http://gyazo.com/c21c8201fa7a571c7665bc7455d88631.png](http://gyazo.com/c21c8201fa7a571c7665bc7455d88631.png)

## For nvim-cmp
```lua
require('cmp').setup({
  sources={{name='look'}}
})
```

## For ddc
```vim
call ddc#custom#patch_global('sources', ['look'])
call ddc#custom#patch_global('sourceOptions', {
      \ '_': {'matchers': ['matcher_head']},
      \ 'look': {'converters': ['loud', 'matcher_head'], 'matchers': [], 'mark': 'l', 'isVolatile': v:true}
      \ })
call ddc#custom#patch_global('sourceParams', {
      \ 'look': {'convertCase': v:true}
      \ })
```

## Alternatives
* [ujihisa/neco-look](https://github.com/ujihisa/neco-look)
* [matsui54/ddc-dictionary](https://github.com/matsui54/ddc-dictionary)
