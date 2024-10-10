local M = {}

-- Helper function to check if specified LSP is attached to the current buffer
local function is_lsp_attached(lsp_name)
  local clients = vim.lsp.get_clients()
  for _, client in ipairs(clients) do
    if client.name == lsp_name and vim.lsp.buf_is_attached(0, client.id) then
      return true
    end
  end
  return false
end

-- Function that waits for specified LSP to attach and then calls the provided callback
function M.wait_for_lsp(lsp_name, callback)
  local timer = vim.loop.new_timer()
  local interval = 100 -- Check every 100ms
  local max_attempts = 50 -- Maximum attempts before timeout (e.g., 5 seconds)

  local attempts = 0

  -- Start the polling loop
  timer:start(
    0,
    interval,
    vim.schedule_wrap(function()
      attempts = attempts + 1

      if is_lsp_attached(lsp_name) then
        -- If LSP is attached, stop the timer and run the callback
        timer:stop()
        timer:close()
        callback()
      elseif attempts >= max_attempts then
        -- Stop checking after max attempts (timeout)
        timer:stop()
        timer:close()
        vim.notify("pyright not activated in time", vim.log.levels.WARN)
      end
    end)
  )
end

-- Function to check for a project root in the current and parent directories
function M.recursive_find_project_root(start_path, folder_name)
  local current_path = start_path

  while current_path ~= "" do
    local target_path = string.format("%s/%s", current_path, folder_name)
    if vim.fn.isdirectory(target_path) == 1 then
      return target_path
    end

    -- Move up to the parent directory
    local parent_path = vim.fn.fnamemodify(current_path, ":h")
    if parent_path == current_path then
      break
    end
    current_path = parent_path
  end
  return nil -- No virtual environment found
end

return M
