local M = {}

local function run_cmd(cmd)
  -- TODO: Look into vim.loop.spawn to ignore stderr
  local handle = io.popen(cmd)
  local result = handle:read("*a")
  handle:close()
  return string.gsub(result, "\n", "")
end

local function git_commit(dir)
  -- Try to get a tag for HEAD.
  local tag = run_cmd(string.format("git -C '%s' describe --tags --exact-match HEAD 2>/dev/null", dir))
  if #tag > 0 then
    return tag
  end
  -- If there isn't a tag, use the commit hash.
  return run_cmd(string.format("git -C '%s' rev-parse HEAD", dir))
end

local function git_remote(dir)
  local cmd = string.format("git -C '%s' config --get remote.origin.url", dir)
  local remote = run_cmd(cmd)

  if string.sub(remote, 1, 15) == "git@github.com:" then
    -- git@github.com:owner/repo
    remote = string.format("https://github.com/%s", string.sub(remote, 16))
  elseif string.sub(remote, 1, 18) == "https://github.com" then
    -- https://github.com/owner/repo
    -- Do nothing, remote is already in good shape.
  else
    error("no GitHub remote found")
  end
  -- Check if the remote ends in .git and remove it if so.
  if string.sub(remote, #remote - 3) == ".git" then
    remote = string.sub(remote, 1, #remote - 4)
  end
  return remote
end

local function git_dir(path)
  local dir = vim.fn.fnamemodify(path, ":h")
  local cmd = string.format("git -C '%s' rev-parse --show-toplevel", dir)
  return run_cmd(cmd)
end

function M.openLine()
  run_cmd('open "' .. M.getGithubUrlLine() .. '"')
end

function M.openSelection()
  run_cmd('open "' .. M.getGithubUrlSelection() .. '"')
end

function M.yankLine()
  vim.api.nvim_command('let @+ = "' .. M.getGithubUrlLine() .. '"')
end

function M.yankSelection()
  vim.api.nvim_command('let @+ = "' .. M.getGithubUrlSelection() .. '"')
end

function M.getGithubUrlLine()
  -- Find the current cursor line number.
  local line = vim.api.nvim_win_get_cursor(0)[1]
  return string.format("%s#L%d", M.getGithubUrlBase(), line)
end

function M.getGithubUrlSelection()
  -- Find the start / end of the last visual range.
  local start_line = vim.fn.line("'<")
  local end_line = vim.fn.line("'>")
  return string.format("%s#L%d-L%d", M.getGithubUrlBase(), start_line, end_line)
end

function M.getGithubUrlBase()
  -- Get the path of the current buffer.
  local current_buffer = vim.api.nvim_get_current_buf()
  local buffer_path = vim.api.nvim_buf_get_name(current_buffer)
  -- Find the git root directory that the file is in.
  local root_dir = git_dir(buffer_path)
  -- Find the current commit.
  local commit = git_commit(root_dir)
  -- Find the remote URL.
  local remote = git_remote(root_dir)
  -- Generate the path relative to the root git directory.
  local relative_path = string.sub(buffer_path, #root_dir + 2)
  -- TODO: If the current branch is not tracked by the remote or is behind, throw an error.
  -- Generate a permalink using the repo, file, commit, and line number info.
  return string.format("%s/blob/%s/%s", remote, commit, relative_path)
end

return M
