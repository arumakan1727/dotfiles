local wezterm = require 'wezterm'

local config = {}
if wezterm.config_builder then
  config = wezterm.config_builder()
end

config.color_scheme = 'Tokyo Night (Gogh)'

config.send_composed_key_when_left_alt_is_pressed = false
config.send_composed_key_when_right_alt_is_pressed = true
config.keys = {
	{
		-- On mac with JIS keyboard
		key = '¥',
		mods = 'CTRL',
		action = wezterm.action.SendKey {
			key = '\\',
			mods = 'CTRL',
		},
	},
	{
		key = 'r',
		mods = 'CTRL|SHIFT',
		action = wezterm.action.ReloadConfiguration,
	}
}

return config
