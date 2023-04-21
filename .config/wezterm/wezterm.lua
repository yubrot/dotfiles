local wezterm = require 'wezterm'
local config = {}

config.audible_bell = 'Disabled'
config.visual_bell = { fade_out_duration_ms = 50 }
config.colors = { visual_bell = '#333333' }
config.font = wezterm.font 'JetBrains Mono'
config.font_size = 14
config.window_frame = { font_size = 14 }
config.keys = {
  {
    key = 't',
    mods = 'CMD',
    action = wezterm.action.SpawnTab,
  },
  {
    key = 'h',
    mods = 'CMD',
    action = wezterm.action.ActivateTabRelative(-1),
  },
  {
    key = 'l',
    mods = 'CMD',
    action = wezterm.action.ActivateTabRelative(1),
  },
}

return config
