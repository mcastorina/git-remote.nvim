# git-remote.nvim

Easily open files in GitHub for sharing or linking.

## Configuration

```lua
-- Normal mode bind formats the current line number.
vim.keymap.set('n', '<leader>ww', '<cmd>lua require("git_remote").openLine()<CR>',
  { silent = true, desc = 'Open remote git URL in browser' })
vim.keymap.set('n', '<leader>wy', '<cmd>lua require("git_remote").yankLine()<CR>',
  { silent = true, desc = 'Yank remote git URL' })
-- Visual mode bind formats with the selected lines.
vim.keymap.set('v', '<leader>ww', '<esc><cmd>lua require("git_remote").openSelection()<CR>',
  { silent = true, desc = 'Open remote git URL in browser' })
vim.keymap.set('v', '<leader>wy', '<esc><cmd>lua require("git_remote").yankSelection()<CR>',
  { silent = true, desc = 'Yank remote git URL' })
```
