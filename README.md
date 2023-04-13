# lua-gf.nvim

Enable `gf` (go to file) in Neovim for Lua and Fennel module paths.

## Install

With `lazy.nvim`:

```lua
-- you may lazy-load on the Lua filetype
{ 'mrjones2014/lua-gf.nvim', ft = 'lua' },
```

## Usage

Consider the code:

```lua
require('some.plugin.module.path')
```

If your cursor is anywhere in the string inside the `require()` call,
with this plugin, you can press `gf` to open the Lua file it corresponds to.
