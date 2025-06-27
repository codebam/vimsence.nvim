local M = {}

local uv = vim.loop
local api = vim.api

local config = {
  client_id = '439476230543245312',
  discord_flatpak = false,
  small_text = 'Neovim',
  small_image = 'neovim',
  editing_large_text = 'Editing a {} file',
  editing_state = 'Workspace: {}',
  editing_details = 'Editing {}',
  file_explorer_text = 'In the file explorer',
  file_explorer_details = 'Searching for files',
  ignored_file_types = {},
  ignored_directories = {},
  custom_icons = {}
}

local start_time = os.time()
local base_activity = {
  details = 'Nothing',
  timestamps = {
    start = start_time
  },
  assets = {
    small_text = config.small_text,
    small_image = config.small_image,
  }
}

local rpc_obj = nil
local timer = nil
local vimsence_init = false

local function load_config()
  local config_path = vim.fn.stdpath('config') .. '/lua/vimsence/vimsence.json'
  if vim.fn.filereadable(config_path) == 1 then
    local file = io.open(config_path, 'r')
    if file then
      local content = file:read('*all')
      file:close()
      local ok, json_config = pcall(vim.json.decode, content)
      if ok and json_config then
        return json_config
      end
    end
  end
  
  local default_config_path = vim.fn.fnamemodify(debug.getinfo(1).source:sub(2), ':h:h:h') .. '/vimsence.json'
  if vim.fn.filereadable(default_config_path) == 1 then
    local file = io.open(default_config_path, 'r')
    if file then
      local content = file:read('*all')
      file:close()
      local ok, json_config = pcall(vim.json.decode, content)
      if ok and json_config then
        return json_config
      end
    end
  end
  
  return { filetypes = {} }
end

local json_config = load_config()
local has_thumbnail = {}
local remap = {}

for _, item in ipairs(json_config.filetypes or {}) do
  table.insert(has_thumbnail, item.name)
  if item.icon then
    remap[item.name] = item.icon
  end
end

local file_explorers = {
  'nerdtree',
  'vimfiler',
  'netrw',
  'neo-tree',
  'nvim-tree'
}

local file_explorer_names = {
  'vimfiler:default',
  'NERD_tree_',
  'NetrwTreeListing',
  'neo-tree',
  'NvimTree'
}

local function contains(list, item)
  for _, v in ipairs(list) do
    if v == item then
      return true
    end
  end
  return false
end

local function contains_fuzzy(list, item)
  for _, v in ipairs(list) do
    if string.find(item, v, 1, true) then
      return true
    end
  end
  return false
end

local function get_filename()
  return vim.fn.expand('%:t')
end

local function get_filetype()
  return vim.bo.filetype
end

local function get_extension()
  return vim.fn.expand('%:e')
end

local function get_directory()
  local cwd = vim.fn.getcwd()
  return vim.fn.fnamemodify(cwd, ':t')
end

local function is_writable()
  return vim.bo.modifiable
end

local discord_rpc = require('vimsence.discord_rpc')

local function initialize_discord()
  if vimsence_init then
    return
  end
  
  if vim.g.vimsence_client_id then
    config.client_id = vim.g.vimsence_client_id
  end
  
  for key, value in pairs(config) do
    local vim_var = 'vimsence_' .. key
    if vim.g[vim_var] ~= nil then
      config[key] = vim.g[vim_var]
    end
  end
  
  base_activity.assets.small_text = config.small_text
  base_activity.assets.small_image = config.small_image
  
  if config.custom_icons then
    for k, v in pairs(config.custom_icons) do
      if not contains(has_thumbnail, v) then
        table.insert(has_thumbnail, v)
      end
      remap[k] = v
    end
  end
  
  rpc_obj = discord_rpc.new(config.client_id, config.discord_flatpak)
  if rpc_obj then
    rpc_obj:set_activity(base_activity)
  end
  
  vimsence_init = true
end

function M.update_presence()
  if not rpc_obj or not rpc_obj:is_connected() then
    return
  end
  
  local activity = vim.deepcopy(base_activity)
  
  local large_image = ''
  local large_text = ''
  local details = ''
  local state = ''
  
  local filename = get_filename()
  local directory = get_directory()
  local filetype = get_filetype()
  
  -- Handle empty values
  if filename == '' then
    filename = 'Unknown'
  end
  if directory == '' then
    directory = 'Unknown'
  end
  
  state = string.format(config.editing_state, directory)
  details = string.format(config.editing_details, filename)
  
  if contains(config.ignored_file_types, filetype) or contains(config.ignored_directories, directory) then
    rpc_obj:set_activity(base_activity)
    return
  end
  
  if filetype and filetype ~= '' and contains(has_thumbnail, filetype) then
    large_text = string.format(config.editing_large_text, filetype)
    
    if remap[filetype] then
      filetype = remap[filetype]
    end
    
    large_image = filetype
  elseif contains(file_explorers, filetype) or contains_fuzzy(file_explorer_names, filename) then
    large_image = 'file-explorer'
    large_text = config.file_explorer_text
    details = config.file_explorer_details
  elseif is_writable() and filename ~= '' then
    large_image = 'none'
    large_text = string.format(config.editing_large_text, 
      filetype ~= '' and filetype or (get_extension() ~= '' and get_extension() or 'Unknown'))
  else
    large_image = 'none'
    large_text = 'Nothing'
    details = 'Nothing'
  end
  
  activity.assets.large_image = large_image
  activity.assets.large_text = large_text
  activity.details = details
  activity.state = state
  
  rpc_obj:set_activity(activity)
end

function M.reconnect()
  if not rpc_obj then
    vim.notify('Vimsence: Plugin not initialized', vim.log.levels.ERROR)
    return
  end
  
  if rpc_obj:reconnect() then
    M.update_presence()
  end
end

function M.disconnect()
  if not rpc_obj then
    vim.notify('Vimsence: Plugin not initialized', vim.log.levels.ERROR)
    return
  end
  
  rpc_obj:close()
end

local function async_wrapper(callback)
  if timer then
    timer:close()
  end
  
  timer = uv.new_timer()
  if timer then
    timer:start(100, 0, function()
      timer:close()
      timer = nil
      vim.schedule(callback)
    end)
  else
    vim.schedule(callback)
  end
end

function M.setup(opts)
  opts = opts or {}
  
  for key, value in pairs(opts) do
    config[key] = value
  end
  
  initialize_discord()
  
  api.nvim_create_user_command('DiscordUpdatePresence', function()
    async_wrapper(M.update_presence)
  end, {})
  
  api.nvim_create_user_command('DiscordReconnect', function()
    async_wrapper(M.reconnect)
  end, {})
  
  api.nvim_create_user_command('DiscordDisconnect', function()
    async_wrapper(M.disconnect)
  end, {})
  
  local group = api.nvim_create_augroup('DiscordPresence', { clear = true })
  api.nvim_create_autocmd({ 'BufNewFile', 'BufRead', 'BufEnter' }, {
    group = group,
    callback = function()
      async_wrapper(M.update_presence)
    end
  })
end

return M