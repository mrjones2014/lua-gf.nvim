if vim.g.lua_gf_loaded then
  return
end
vim.g.lua_gf_loaded = true

local fmt = string.format

-- Iterator that splits a string on a given delimiter
local function split(str, delim)
  delim = delim or '%s'
  return string.gmatch(str, fmt('[^%s]+', delim))
end

-- Search for lua traditional include paths.
-- This mimics how require internally works.
local function include_paths(fname)
  local paths = string.gsub(package.path, '%?', fname)
  for path in split(paths, '%;') do
    if vim.fn.filereadable(path) == 1 then
      return path
    end
  end
end

-- Search for nvim lua include paths
local function include_rtpaths(fname, ext)
  ext = ext or 'lua'
  local rtpaths = vim.api.nvim_list_runtime_paths()
  local modfile, initfile = fmt('%s.%s', fname, ext), fmt('init.%s', ext)
  for _, path in ipairs(rtpaths) do
    -- Look on runtime path for 'lua/*.lua' files
    local path1 = table.concat({ path, ext, modfile }, '/')
    if vim.fn.filereadable(path1) == 1 then
      return path1
    end
    -- Look on runtime path for 'lua/*/init.lua' files
    local path2 = table.concat({ path, ext, fname, initfile }, '/')
    if vim.fn.filereadable(path2) == 1 then
      return path2
    end
  end
end

-- Global function that searches the path for the required file
function _G.lua_rtp_find_required_path(module)
  pcall(require, module) -- for lazy-loading environments, make sure it's on runtimepath
  -- Look at package.config for directory separator string (it's the first line)
  local sep = string.match(package.config, '^[^\n]')
  -- Properly change '.' to separator (probably '/' on *nix and '\' on Windows)
  local fname = vim.fn.substitute(module, '\\.', sep, 'g')
  return include_paths(fname) or include_rtpaths(fname)
end

local function attach()
  if vim.bo.filetype == 'lua' or vim.bo.filetype == 'fennel' then
    -- Set options to open require with gf
    vim.opt_local.include = [=[\v<((do|load)file|require)\s*\(?['"]\zs[^'"]+\ze['"]]=]
    vim.opt_local.includeexpr = 'v:lua.lua_rtp_find_required_path(v:fname)'
  end
end

vim.api.nvim_create_autocmd({ 'BufRead', 'BufNewFile', 'FileType' }, {
  pattern = '*.lua',
  callback = attach,
})

-- For lazy-loading environments, if current buffer is Lua, then run the autocmd
if vim.bo.ft == 'lua' or vim.bo.ft == 'fennel' then
  vim.schedule(attach)
end
