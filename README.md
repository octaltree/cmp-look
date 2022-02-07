# look source for [nvim-cmp](https://github.com/hrsh7th/nvim-cmp)
This is [look](https://man7.org/linux/man-pages/man1/look.1.html) source for [hrsh7th/nvim-cmp](https://github.com/hrsh7th/nvim-cmp) and [Shougo/ddc.vim](https://github.com/Shougo/ddc.vim) inspired by [ujihisa/neco-look](https://github.com/ujihisa/neco-look).

![http://gyazo.com/c21c8201fa7a571c7665bc7455d88631.png](http://gyazo.com/c21c8201fa7a571c7665bc7455d88631.png)

## For nvim-cmp
```lua
require('cmp').setup({
    sources = {
        {
            name = 'look',
            keyword_length = 2,
            option = {
                convert_case = true,
                loud = true
                --dict = '/usr/share/dict/words'
            }
        }
    }
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
      \ 'look': {
      \   'convertCase': v:true,
      \   'dict': v:null
      \ }})
```

## Configuration options

### convert_case cmp/ convertCase ddc (type: boolean)
Convert the candidates to match the input characters in the case.

### loud cmp (type: boolean)
Convert the candidates to UPPERCASE if all input characters are uppercase.

### loud ddc (converter)
A converter instead of option for ddc

### dict cmp ddc (type: null|string)
null or specify the dict file path

## Alternatives
* [ujihisa/neco-look](https://github.com/ujihisa/neco-look)
* [matsui54/ddc-dictionary](https://github.com/matsui54/ddc-dictionary)
