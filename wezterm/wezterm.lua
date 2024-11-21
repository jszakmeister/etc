-- Pull in the wezterm API
local wezterm = require 'wezterm'

-- This will hold the configuration.
local config = wezterm.config_builder()

config.font = wezterm.font('Hack')
config.font_size = 16
config.line_height = 1.11
config.initial_cols = 132
config.initial_rows = 43

-- Configure the tab bar
config.window_frame = {
  -- Bump up the font size for tabs.
  font_size = 14.0,
}

config.enable_scroll_bar = true

config.color_scheme = 'iTerm2 Tango Dark'

-- and finally, return the configuration to wezterm
return config
