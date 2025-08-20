-- Pull in the wezterm API
local wezterm = require("wezterm")

-- This will hold the configuration.
local config = wezterm.config_builder()

config.color_scheme = "Catppuccin Macchiato (Gogh)"
config.font = wezterm.font({
	family = "JetBrains Mono",
	weight = "Bold",
	stretch = "Expanded",
})
config.font_size = 18

-- window
config.window_decorations = "RESIZE"
config.window_background_opacity = 0.8
config.macos_window_background_blur = 20
config.enable_scroll_bar = false
config.enable_wayland = false
config.front_end = "OpenGL"
config.max_fps = 75
config.default_cursor_style = "BlinkingBlock"
config.animation_fps = 1
config.cursor_blink_rate = 500

-- Padding
config.window_padding = { left = 0, right = 0, top = 0, bottom = 0 }

-- Tab bar
config.enable_tab_bar = false
config.hide_tab_bar_if_only_one_tab = true
config.use_fancy_tab_bar = true
config.colors = {
	tab_bar = {
		background = "#282828",
		active_tab = {
			bg_color = "#458588",
			fg_color = "#ffffff",
			intensity = "Bold",
		},
		inactive_tab = {
			bg_color = "#3c3836",
			fg_color = "#a89984",
		},
	},
}

-- color scheme toggling
wezterm.on("toggle-colorscheme", function(window, _)
	local overrides = window:get_config_overrides() or {}
	if overrides.color_scheme == "Catppuccin Mocha (Gogh)" then
		overrides.color_scheme = "Catppuccin Macchiato (Gogh)"
	else
		overrides.color_scheme = "Catppuccin Mocha (Gogh)"
	end
	window:set_config_overrides(overrides)
end)

-- opacity toggling
wezterm.on("toggle-opacity", function(window, _)
	local overrides = window:get_config_overrides() or {}
	if overrides.window_background_opacity == 1.0 then
		overrides.window_background_opacity = 0.8
	else
		overrides.window_background_opacity = 1.0
	end
	window:set_config_overrides(overrides)
end)

-- Inactive pane visibility
config.inactive_pane_hsb = {
	saturation = 0.9,
	brightness = 0.6,
}

-- keymaps
config.keys = {
	{
		key = "E",
		mods = "CTRL|SHIFT|ALT",
		action = wezterm.action.EmitEvent("toggle-colorscheme"),
	},
	{
		key = "O",
		mods = "CTRL|SHIFT|ALT",
		action = wezterm.action.EmitEvent("toggle-opacity"),
	},
}

-- and finally, return the configuration to wezterm
return config
