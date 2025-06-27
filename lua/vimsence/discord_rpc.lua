local M = {}

local uv = vim.loop
local bit = require('bit')

local OP_HANDSHAKE = 0
local OP_FRAME = 1
local OP_CLOSE = 2
local OP_PING = 3
local OP_PONG = 4

local function pack_u32_le(value)
  return string.char(
    bit.band(value, 0xFF),
    bit.band(bit.rshift(value, 8), 0xFF),
    bit.band(bit.rshift(value, 16), 0xFF),
    bit.band(bit.rshift(value, 24), 0xFF)
  )
end

local function unpack_u32_le(data, offset)
  offset = offset or 1
  local b1, b2, b3, b4 = string.byte(data, offset, offset + 3)
  return b1 + bit.lshift(b2, 8) + bit.lshift(b3, 16) + bit.lshift(b4, 24)
end

local DiscordRpc = {}
DiscordRpc.__index = DiscordRpc

function DiscordRpc:new(client_id, discord_flatpak)
  local self = setmetatable({}, DiscordRpc)
  self.client_id = client_id
  self.discord_flatpak = discord_flatpak or false
  self.connected = false
  self.pipe = nil
  self.socket = nil
  
  self:_connect()
  
  return self
end

function DiscordRpc:_connect()
  if vim.fn.has('win32') == 1 then
    self:_connect_windows()
  else
    self:_connect_unix()
  end
end

function DiscordRpc:_connect_windows()
  for i = 0, 9 do
    local pipe_name = string.format('\\\\.\\pipe\\discord-ipc-%d', i)
    local pipe = uv.new_pipe(false)
    
    if pipe then
      local success = pcall(function()
        pipe:connect(pipe_name, function(err)
          if not err then
            self.pipe = pipe
            self:_do_handshake()
          end
        end)
      end)
      
      if success and self.pipe then
        break
      end
    end
  end
end

function DiscordRpc:_connect_unix()
  local temp_dirs = {
    os.getenv('XDG_RUNTIME_DIR'),
    os.getenv('TMPDIR'),
    os.getenv('TMP'),
    os.getenv('TEMP'),
    '/tmp'
  }
  
  local base_dir = nil
  for _, dir in ipairs(temp_dirs) do
    if dir and vim.fn.isdirectory(dir) == 1 then
      base_dir = dir
      break
    end
  end
  
  if not base_dir then
    return
  end
  
  local position = self.discord_flatpak and 'app/com.discordapp.Discord/' or ''
  
  for i = 0, 9 do
    local socket_path = string.format('%s/%sdiscord-ipc-%d', base_dir, position, i)
    
    if vim.fn.filereadable(socket_path) == 1 then
      local socket = uv.new_pipe(false)
      
      if socket then
        local success = false
        socket:connect(socket_path, function(err)
          if not err then
            self.socket = socket
            success = true
            self:_do_handshake()
          end
        end)
        
        if success then
          break
        end
      end
    end
  end
end

function DiscordRpc:_do_handshake()
  local handshake_data = {
    v = 1,
    client_id = self.client_id
  }
  
  self:_send_packet(handshake_data, OP_HANDSHAKE)
  
  vim.defer_fn(function()
    self:_recv_packet(function(op, data)
      if op == OP_FRAME and data.cmd == 'DISPATCH' and data.evt == 'READY' then
        self.connected = true
        vim.schedule(function()
          vim.notify('Vimsence: Connected to Discord', vim.log.levels.INFO)
        end)
      end
    end)
  end, 100)
end

function DiscordRpc:_send_packet(data, op)
  op = op or OP_FRAME
  local json_data = vim.json.encode(data)
  local data_bytes = json_data
  local header = pack_u32_le(op) .. pack_u32_le(#data_bytes)
  local packet = header .. data_bytes
  
  if self.pipe then
    self.pipe:write(packet)
  elseif self.socket then
    self.socket:write(packet)
  end
end

function DiscordRpc:_recv_packet(callback)
  local handle = self.pipe or self.socket
  if not handle then
    return
  end
  
  handle:read_start(function(err, data)
    if err or not data then
      return
    end
    
    if #data >= 8 then
      local op = unpack_u32_le(data, 1)
      local length = unpack_u32_le(data, 5)
      
      if #data >= 8 + length then
        local payload = string.sub(data, 9, 8 + length)
        local decoded_data = vim.json.decode(payload)
        callback(op, decoded_data)
      end
    end
  end)
end

function DiscordRpc:set_activity(activity)
  if not self:is_connected() then
    return
  end
  
  local data = {
    cmd = 'SET_ACTIVITY',
    args = {
      pid = vim.fn.getpid(),
      activity = activity
    },
    nonce = vim.fn.reltimestr(vim.fn.reltime())
  }
  
  self:_send_packet(data)
end

function DiscordRpc:is_connected()
  return self.connected and (self.pipe or self.socket)
end

function DiscordRpc:reconnect()
  self:close()
  vim.defer_fn(function()
    self:_connect()
  end, 500)
  return true
end

function DiscordRpc:close()
  self.connected = false
  
  if self.pipe then
    self.pipe:close()
    self.pipe = nil
  end
  
  if self.socket then
    self.socket:close()
    self.socket = nil
  end
end

function M.new(client_id, discord_flatpak)
  return DiscordRpc:new(client_id, discord_flatpak)
end

return M