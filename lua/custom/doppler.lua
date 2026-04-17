local M = {}

local mise_files = { '.mise.toml', 'mise.toml', '.mise.local.toml', 'mise.local.toml' }

function M.project_uses_doppler(start)
  start = start or vim.fn.getcwd()
  local matches = vim.fs.find(mise_files, { upward = true, path = start, limit = math.huge })
  for _, file in ipairs(matches) do
    local fh = io.open(file, 'r')
    if fh then
      local content = fh:read '*a'
      fh:close()
      local val = content:match 'USING_DOPPLER%s*=%s*"([^"]*)"'
        or content:match "USING_DOPPLER%s*=%s*'([^']*)'"
        or content:match 'USING_DOPPLER%s*=%s*([^%s\n]+)'
      if val == '1' or val == 'true' then return true end
    end
  end
  return false
end

local loaded_for = nil

local function apply(cwd, result)
  if result.code ~= 0 then
    local msg = (result.stderr or ''):gsub('%s+$', '')
    vim.notify('doppler: ' .. (msg ~= '' and msg or 'command failed'), vim.log.levels.WARN)
    return
  end
  local ok, secrets = pcall(vim.json.decode, result.stdout)
  if not ok or type(secrets) ~= 'table' then
    vim.notify('doppler: failed to parse secrets', vim.log.levels.WARN)
    return
  end
  for key, value in pairs(secrets) do
    if type(value) == 'string' then vim.env[key] = value end
  end
  loaded_for = cwd
end

function M.load_env(opts)
  opts = opts or {}
  local cwd = vim.fn.getcwd()
  if not opts.force and loaded_for == cwd then return end
  if not M.project_uses_doppler(cwd) then return end
  if vim.fn.executable 'doppler' == 0 then
    vim.notify('doppler: binary not found on PATH', vim.log.levels.WARN)
    return
  end

  local cmd = { 'doppler', 'secrets', 'download', '--no-file', '--format', 'json' }
  if opts.sync then
    apply(cwd, vim.system(cmd, { cwd = cwd, text = true }):wait())
  else
    vim.system(cmd, { cwd = cwd, text = true }, function(result) vim.schedule(function() apply(cwd, result) end) end)
  end
end

function M.setup()
  vim.api.nvim_create_user_command('DopplerReload', function() M.load_env { force = true, sync = true } end, { desc = 'Reload doppler secrets into vim.env' })

  vim.api.nvim_create_user_command('DopplerReloadDB', function()
    pcall(vim.cmd, 'DBUIClose')
    M.load_env { force = true, sync = true }
    pcall(vim.fn['db_ui#reset_state'])
    vim.cmd 'DBUI'
  end, { desc = 'Reload doppler secrets and restart DBUI' })
end

return M
