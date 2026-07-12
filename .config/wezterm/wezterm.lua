local wezterm = require 'wezterm'

local config = {}

config.audible_bell = 'Disabled'
config.visual_bell = { fade_out_duration_ms = 50 }
config.enable_scroll_bar = true
config.enable_tab_bar = false
config.show_tabs_in_tab_bar = false
config.show_new_tab_button_in_tab_bar = false
config.colors = { visual_bell = '#333333' }
config.font = wezterm.font 'UDEV Gothic NFLG'
config.font_size = 16
config.window_frame = { font_size = 16 }
config.send_composed_key_when_left_alt_is_pressed = true

return config
