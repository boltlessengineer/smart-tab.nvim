# smart-tab.nvim

simple plugin implements smart-tab feature from [Helix
23.10](https://helix-editor.com/news/release-23-10-highlights/#smart-tab).

> Smart Tab is a new feature bound to the tab key in the default keymap.
> When you press tab and the line to the left of the cursor isn't all
> whitespace, the cursor will jump to the end of the syntax tree's
> parent node.

> This is useful in languages like Nix for adding semicolons at the end
> of an attribute set or jumping to the end of a block in a C-like
> language

## Note for differences

I haven't used or looked inside helix's implementation. I just borrowed
the idea, so behavior might differ from Helix's. Let me know if you have
any suggestions for improvement.

## Setup

```lua
require('smart-tab').setup({
    -- default options:
    -- list of tree-sitter node types to filter
    skips = { "string_content" },
    -- default mapping, set `false` if you don't want automatic mapping
    mapping = "<tab>",
    -- filetypes to exclude
    exclude_filetypes = {}
})
```

### Manual Keymap

```lua
vim.keymap.set("i", "<tab>", require('smart-tab').smart_tab)
```

> NOTE: this won't fallback to `<tab>`

## Usage

1.  Press `<tab>` on insert mode.

2.  If cursor is at non-blank line, cursor jumps to end of the current
    node

    - If current node type is in `skips`, cursor jumps to end of it's
      parrent node

    - If cursor is at blank line, literal `<tab>` is inserted

### Examples

Normal smart-tab.

```javascript
let obj = {
    key = 1,| // <- press <tab> here
}
let obj = {
    key = 1,
}| // <- cursor moves to here
```

Smart tab with skipping some node types.

```javascript
let str = "abc|de"
//            ^ press <tab> here
let str = "abcde"|
//               ^ cursor moves to here (skipping `string_content` node)
```

You can still insert `<tab>` on blank line.

```javascript
let example3 = {
| // <- press <tab> in blank line
}
let example3 = {
    | // literal `<tab>` is inserted
}
```
