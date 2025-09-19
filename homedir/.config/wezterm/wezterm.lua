local wezterm = require("wezterm")

local config = {}
if wezterm.config_builder then
	config = wezterm.config_builder()
end

config.window_background_opacity = 0.85

config.color_scheme = "Tokyo Night (Gogh)"
config.colors = {
	cursor_bg = "#f0f0f0",
	cursor_fg = "#000000",
	cursor_border = "#ff0000",
}

config.font_size = 13.0
config.font = wezterm.font_with_fallback({
	{
		family = 'Moralerspace Radon HWNF',
		weight = 'Regular',
	},
	{
		family = 'JetBrainsMonoNL NF',
		weight = 'Regular',
	},
	{
		family = "UDEV Gothic NF",
		weight = "Regular",
	},
	"monospace",
})

config.audible_bell = "Disabled"

config.send_composed_key_when_left_alt_is_pressed = false
config.send_composed_key_when_right_alt_is_pressed = true
config.keys = {
	{
		-- On mac with JIS keyboard
		key = "¥",
		mods = "CTRL",
		action = wezterm.action.SendKey({
			key = "\\",
			mods = "CTRL",
		}),
	},
	{
		-- On mac with JIS keyboard
		key = "¥",
		action = wezterm.action.SendKey({
			key = "\\",
		}),
	},
	{
		key = "r",
		mods = "CTRL|SHIFT",
		action = wezterm.action.ReloadConfiguration,
	},
}

return config
