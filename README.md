# git-opener.nvim

Easily open files in GitHub for sharing or linking.

## Configuration

```lua
-- Normal mode bind opens at the current line number.
vim.keymap.set('n', '<leader>W', '<cmd>lua require("github_opener").openLine()<CR>',
  { silent = true })
-- Visual mode bind opens with the selected lines.
vim.keymap.set('v', '<leader>W', '<esc><cmd>lua require("github_opener").openSelection()<CR>',
  { silent = true })
```
