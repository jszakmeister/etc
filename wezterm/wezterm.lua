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

-- If you have local configuration changes, create
-- ~/.config/wezterm/local_config.lua and put the following into it:
--   local mod = {}
--
--   function mod.update_config(config)
--       ### config updates go here
--   end
--
--   return mod
has_local, local_config = pcall(require, "local_config")
if has_local then
    local_config.update_config(config)
end

-- and finally, return the configuration to wezterm
return config
