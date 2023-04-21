local wezterm = require 'wezterm'

local function override_config(name, modify, defval)
  return function(window, pane)
    local overrides = window:get_config_overrides() or {}
    local val = overrides[name] or defval
    overrides[name] = modify(val)
    window:set_config_overrides(overrides)
  end
end

wezterm.on('inc-font-size', override_config('font_size', function(n) return n + 2 end, 16))
wezterm.on('dec-font-size', override_config('font_size', function(n) return n - 2 end, 16))

local config = {}

config.audible_bell = 'Disabled'
config.visual_bell = { fade_out_duration_ms = 50 }
config.enable_scroll_bar = true
config.colors = { visual_bell = '#333333' }
config.font = wezterm.font 'JetBrains Mono'
config.font_size = 16
config.window_frame = { font_size = 16 }
config.keys = {}

local function add_command(key, action)
  table.insert(config.keys, {
    key = key,
    mods = 'CMD',
    action = action,
  })
  table.insert(config.keys, {
    key = key,
    mods = 'CTRL',
    action = action,
  })
end

add_command('t', wezterm.action.SpawnTab('DefaultDomain'))
add_command('h', wezterm.action.ActivateTabRelative(-1))
add_command('l', wezterm.action.ActivateTabRelative(1))
add_command('+', wezterm.action.EmitEvent('inc-font-size'))
add_command('-', wezterm.action.EmitEvent('dec-font-size'))

return config
